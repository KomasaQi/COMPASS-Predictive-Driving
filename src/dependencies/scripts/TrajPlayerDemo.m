clc
clear
close
%% STEP 1 生成路网并画图 
% ************************************************************************
net = RoadNetwork(); % 初始化路网
scale_factor = 80;   % 设置几何缩放因子
nodes = [1, 5;       % 设置节点
         6, 6;
         2,10;
        -5, 8;
        -4, 4;
        -4, 0;
         1, 1;
         5, 2;
        15,15]*scale_factor;

for i = 1:size(nodes,1) % 将节点加入路网
    net = net.add_node(nodes(i,:));
end

% 设置每条道路的中间节点（至少有一个点）
middle_cv{1,2}=[2,5.2;3.5,5.2]*scale_factor;
middle_cv{1,3}=[0.5 7;2,8.5]*scale_factor;
middle_cv{2,3}=[5 7;8,9;5,11]*scale_factor;
middle_cv{3,4}=[-1,9;-3,9]*scale_factor;
middle_cv{4,5}=[-4.5,6]*scale_factor;
middle_cv{1,5}=[-2,4.2]*scale_factor;
middle_cv{1,7}=[2,3]*scale_factor;
middle_cv{7,8}=[2,1]*scale_factor;
middle_cv{8,2}=[6,3]*scale_factor;
middle_cv{6,7}=[-1,0]*scale_factor;
middle_cv{5,6}=[-3,3;-4,1]*scale_factor;
middle_cv{2,9}=[8,6;10,8;15,6]*scale_factor;

laneNum = 3;      % 设置单侧车道数量
laneWidth = 3.5;  % 道路宽度


% figure

for node1_num = 1:size(middle_cv,1)
    for node2_num = 1:size(middle_cv,2)
        if ~isempty(middle_cv{node1_num,node2_num})
            [Road1,Road2] = net.create2WayRoad(node1_num,node2_num,middle_cv{node1_num,node2_num},[laneNum,laneNum],laneWidth);
            net = net.add2WayRoad(node1_num,node2_num,Road1,Road2);
            % Road1.show(-1)
            % Road2.show(-1)
        end
    end
end
%% 构建道路场景
% 系统仿真时间步（以及车辆控制器离散时间步）
System_Ts = 0.05;
Simulation_tspan = [0 60];
current_time = Simulation_tspan(1);
iteration_tot_num = (Simulation_tspan(2)-Simulation_tspan(1))/System_Ts+1;

% 定义光照角度
light_angle = 195;

%场景初始化
scenario = drivingScenario;       %初始化场景
scenario.SampleTime = System_Ts;  %修改采样时间

%建立道路
marking = [laneMarking('Solid') ...
	laneMarking('Dashed') laneMarking('Dashed') ...
    laneMarking('DoubleSolid','Color','yellow') ...
    laneMarking('Dashed') laneMarking('Dashed') ...
    laneMarking('Solid')];          %分界线线型
laneSpecification = lanespec(6,'Marking',marking);        %道路规范

for node1 = 1:length(net.nodes)
    for node2 = node1+1:length(net.nodes)
        if  isempty(net.Roads{node1,node2})
            continue
        end
        road(scenario,net.Roads{node1,node2}.center,'Lanes',laneSpecification);    %生成道路
    end
end
net.proxyMat
ax = figure;
fill_scale = 20*scale_factor;
% fill(fill_scale*[1,1,-1,-1],fill_scale*[-1,1,1,-1],[0,118,58]/255)
% 定义图像大小
image_size = [2256, 2256];

% 生成随机噪点数据
color_sc_factor = 0.1;
noise1 = color_sc_factor*rand(image_size);
noise2 = color_sc_factor*rand(image_size);
noise3 = color_sc_factor*rand(image_size);

% 创建偏向深绿色但带有其他色相变化的噪点图像
green_noise_img = 5.9*ones([image_size, 3]); % 创建 RGB 图像矩阵

% 设置色相偏移值
hue_shift = 1.0; % 色相偏移值，假设为偏向深绿色

% 将随机噪点映射到 RGB 图像的不同通道上，并应用色相偏移
green_noise_img(:, :, 1) = noise1; % 将随机噪点映射到绿色通道
green_noise_img(:, :, 2) = mod(noise2+0.6*hue_shift,1); % 在红色通道上应用色相偏移
green_noise_img(:, :, 3) = mod(noise3-0.9*hue_shift,1); % 在蓝色通道上应用色相偏移


% 显示整体偏向深绿色但带有其他色相变化的噪点图像
% 对图像进行高斯模糊处理
sigma = 1.5; % 高斯核的标准差
green_noise_img_blur = imgaussfilt(green_noise_img, sigma);

% 显示模糊处理后的图像
imagesc('XData', [-1,1]*1000, 'YData', [-1,1]*1000, 'CData',green_noise_img_blur*0.6);


plot(scenario, 'Parent',gca);
for i =1:size(nodes,1)
    text(nodes(i,1),nodes(i,2),num2str(i));
end
pause(0.5)
xlim([-4,4]*scale_factor)
ylim([3,10]*scale_factor)

for node1 = 1:length(net.nodes)
    for node2 = node1+1:length(net.nodes)
        if  isempty(net.Roads{node1,node2})
            continue
        end
        net.Roads{node1,node2}.show(-1);
        net.Roads{node2,node1}.show(-1);
    end
end

%% 相关车辆参数

% 定义随机数生成种子
rng(13);

% 定义车辆1*****************************************************
% 状态量设置
initpos.delta = 0;      % 初始前轮转角
initpos = GenerateInitpos(initpos,6,7,1,80,net);% 根据
initpos.spd = 20;       % 初始速度 m/s
initpos.acc = 0;        % 初始加速度 m/s2
% 车辆参数设置
veh_params.L_ab = 2.90; % 轴距 m
veh_params.L = 4.80;    % 车长 m
veh_params.W = 1.75;    % 车宽 m
veh_params.Class = 'passenger_car';
% 控制器参数设置
ctrller_params.Ts = System_Ts;
% 车辆限制设置
cons_params.delta_max = 30/180*pi; % 前轮转角限制 rad
% 规划器参数设置
planning_params.roadnet = net;
planning_params.current_node = 6;
planning_params.destination_node=1;
% 决策器设置：换道决策MOBIL模型
mobil_params.p = 0.5;             % 礼让度
mobil_params.delta_a = 0.5;       % 加速度受益阈值
mobil_params.a_bias = [0,0]; % 左/右换道受益偏置

vehicles{1} = Vehicle(initpos,veh_params,ctrller_params,cons_params,mobil_params,planning_params);

% 定义车辆2
vehicles{2} = Vehicle(initpos,veh_params,ctrller_params,cons_params,mobil_params,planning_params);


veh_num = length(vehicles);


% colorMap = {'blue','red','green','blue','red','green','cyan','blue','red','green','blue','red','green','cyan'};
colorMap = {[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.95,0.95,0.95],[0.95,0.95,0.95]};


%% 赋予轨迹
start_node = 6;
end_node = 7;
path1 = net.Roads{start_node,end_node}.lanes{1};
path2 = net.Roads{start_node,end_node}.lanes{2}(30:end,:);
time_series1 = linspace(Simulation_tspan(1),Simulation_tspan(2),size(path1,1))';
time_series2 = linspace(Simulation_tspan(1),Simulation_tspan(2),size(path2,1))';

vehicles{1}.trajectory = Trajectory(path1(:,1),path1(:,2),time_series1);
vehicles{2}.trajectory = Trajectory(path2(:,1),path2(:,2),time_series2);

%% 播放轨迹
jump_list = []; % 暂时不需要跳过某辆车


% 仿真前初始化一下
veh_dot{veh_num}=[];
veh_text{veh_num}=[];
for iters = 1:iteration_tot_num
    tic

    % 进行轨迹规划并步进
    for i = 1:veh_num 
        vehicles{i} = vehicles{i}.stepWithTraj(current_time);
        if ~isempty(veh_dot{i})
            for part_num = 1:length(veh_dot{i})
                delete(veh_dot{i}{part_num})
            end
        end
        delete(veh_text{i})
        hold on % 打印一下所有车的编号
        veh_dot{i} = vehicles{i}.showImg(light_angle,current_time);
        veh_text{i} = text(vehicles{i}.pos(1),vehicles{i}.pos(2),num2str(i));
        hold off
    end

    [xlimit,ylimit]=getBoxVisionLimit(vehicles);
    xlim(xlimit)
    ylim(ylimit)
    toc
    pause(0.0001)
    disp(num2str(iters))
    current_time = current_time + System_Ts;
end


