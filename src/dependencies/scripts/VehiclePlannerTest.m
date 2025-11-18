clc
clear
close
%% STEP 1 生成路网并画图 
% ************************************************************************

roadnet = RoadNetwork(); % 初始化路网
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
    roadnet = roadnet.add_node(nodes(i,:));
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
            [Road1,Road2] = roadnet.create2WayRoad(node1_num,node2_num,middle_cv{node1_num,node2_num},[laneNum,laneNum],laneWidth);
            roadnet = roadnet.add2WayRoad(node1_num,node2_num,Road1,Road2);
            % Road1.show(-1)
            % Road2.show(-1)
        end
    end
end
%% 构建道路场景
% 系统仿真时间步（以及车辆控制器离散时间步）
System_Ts = 0.1;
Simulation_tspan = [0 60];
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

for node1 = 1:length(roadnet.nodes)
    for node2 = node1+1:length(roadnet.nodes)
        if  isempty(roadnet.Roads{node1,node2})
            continue
        end
        road(scenario,roadnet.Roads{node1,node2}.center,'Lanes',laneSpecification);    %生成道路
    end
end
roadnet.proxyMat
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

for node1 = 1:length(roadnet.nodes)
    for node2 = node1+1:length(roadnet.nodes)
        if  isempty(roadnet.Roads{node1,node2})
            continue
        end
        roadnet.Roads{node1,node2}.show(-1);
        roadnet.Roads{node2,node1}.show(-1);
    end
end

%% 相关车辆参数
% 开始节点，下一节点，终点节点
star_node = 6;
next_node = 7;
goal_node = 9;
% 定义随机数生成种子
rng(13);

% 定义车辆1*****************************************************
% 状态量设置
initpos.delta = 0;      % 初始前轮转角
initpos = GenerateInitpos(initpos,star_node,next_node,1,80,roadnet);% 根据
initpos.spd = 20;       % 初始速度 m/s
initpos.acc = 0;        % 初始加速度 m/s2
% 车辆参数设置
veh_params.L_ab = 4.90; % 轴距 m
veh_params.L = 4.80;    % 车长 m
veh_params.W = 1.75;    % 车宽 m
veh_params.Class = 'passenger_car';
% 控制器参数设置
ctrller_params.Ts = System_Ts;
% 车辆限制设置
cons_params.delta_max = 30/180*pi; % 前轮转角限制 rad
% 规划器参数设置
planning_params.roadnet = roadnet;
planning_params.current_node = star_node;
planning_params.destination_node=goal_node;
% 决策器设置：换道决策MOBIL模型
mobil_params.p = 0.5;             % 礼让度
mobil_params.delta_a = 0.5;       % 加速度受益阈值
mobil_params.a_bias = [0,0]; % 左/右换道受益偏置

vehicles{1} = Vehicle(initpos,veh_params,ctrller_params,cons_params,mobil_params,planning_params);
vehicles{1}.longictrller.v_des = 17;
vehicles{1}.longictrller.delta = 4;
vehicles{1}.longictrller.a_max=3;

% 定义车辆2
initpos = GenerateInitpos(initpos,star_node,next_node,2,60,roadnet);
initpos.spd = 25; % 车辆2的初始速度
vehicles{2} = Vehicle(initpos,veh_params,ctrller_params,cons_params,mobil_params,planning_params);
vehicles{2}.longictrller.v_des = 20;
vehicles{2}.longictrller.delta = 100;
vehicles{2}.iscrazy = 1;% 设置为疯狂车辆（车速目标极高）
vehicles{2}.longictrller.a_max=4;

initpos = GenerateInitpos(initpos,star_node,next_node,3,80,roadnet);
vehicles{3} = Vehicle(initpos,veh_params,ctrller_params,cons_params,mobil_params,planning_params);
vehicles{3}.longictrller.v_des = 20;
vehicles{3}.longictrller.delta = 5;
vehicles{3}.iscrazy = 1;% 设置为疯狂车辆（车速目标极高）
vehicles{3}.longictrller.a_max=4;

initpos = GenerateInitpos(initpos,star_node,next_node,1,120,roadnet);
vehicles{4} = Vehicle(initpos,veh_params,ctrller_params,cons_params,mobil_params,planning_params);
vehicles{4}.longictrller.v_des = 20;
vehicles{4}.longictrller.delta = 5;

initpos = GenerateInitpos(initpos,star_node,next_node,2,150,roadnet);
vehicles{5} = Vehicle(initpos,veh_params,ctrller_params,cons_params,mobil_params,planning_params);
vehicles{5}.longictrller.v_des = 20;
vehicles{5}.longictrller.delta = 5;

initpos = GenerateInitpos(initpos,star_node,next_node,3,160,roadnet);
vehicles{6} = Vehicle(initpos,veh_params,ctrller_params,cons_params,mobil_params,planning_params);
vehicles{6}.longictrller.v_des = 20;
vehicles{6}.longictrller.delta = 5;
vehicles{6}.longictrller.a_max=2.5;

initpos = GenerateInitpos(initpos,star_node,next_node,2,170,roadnet);
initpos.spd = 5; % 车辆7的初始速度
vehicles{7} = Vehicle(initpos,veh_params,ctrller_params,cons_params,mobil_params,planning_params);
vehicles{7}.longictrller.v_des = 20;
vehicles{7}.longictrller.delta = 20;
vehicles{7}.longictrller.a_max=2.5;

initpos = GenerateInitpos(initpos,star_node,next_node,3,200,roadnet);
initpos.spd = 5; % 车辆8的初始速度
vehicles{8} = Vehicle(initpos,veh_params,ctrller_params,cons_params,mobil_params,planning_params);
vehicles{8}.longictrller.v_des = 20;
vehicles{8}.longictrller.delta = 20;


veh_num = length(vehicles);


% colorMap = {'blue','red','green','blue','red','green','cyan','blue','red','green','blue','red','green','cyan'};
colorMap = {[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.95,0.95,0.95],[0.95,0.95,0.95]};
%% 为每辆车生成仿真数据记录
datalogs{veh_num}=[];
for i = 1:veh_num
    datalogs{i}=Vehicle_Dataloger(Simulation_tspan,System_Ts);
end


%% 测试全局MOBIL换道函数
jump_list = []; % 暂时不需要跳过某辆车


% 仿真前初始化一下
veh_dot{veh_num}=[];
veh_text{veh_num}=[];
veh_path{veh_num}=[];
for iters = 1:iteration_tot_num
    tic
    % 进行换道决策
    for i = 1:veh_num
        vehicles = GlobalMobile(vehicles,jump_list,roadnet,i);
    end
    
    % 打印轨迹规划结果
    for i = 1:veh_num
        disp(['第' num2str(i) '辆车：' ])
        disp(num2str(vehicles{i}.planner.surr_veh_ids))
        disp(num2str(vehicles{i}.planner.surr_veh_inteqldist))
    end

    for i = 1:veh_num
        disp(['第' num2str(i) '辆车：'...
            num2str(vehicles{i}.planner.current_lane_id) ' -> ' ...
            num2str(vehicles{i}.planner.target_lane_id)])
    end
    % 进行轨迹规划并步进
    for i = 1:veh_num 
        datalogs{i} = datalogs{i}.logData(vehicles{i}); % 记录车辆数据
        front_veh_id = vehicles{i}.planner.surr_veh_ids(1,2);
        if front_veh_id==0
            vehicles{i} = vehicles{i}.step([]);
        else
            vehicles{i} = vehicles{i}.step(vehicles{front_veh_id});
        end
        

        if ~isempty(veh_dot{i})
            for part_num = 1:length(veh_dot{i})
                delete(veh_dot{i}{part_num})
            end
        end
        % delete(veh_dot{i})
        delete(veh_text{i})
        delete(veh_path{i})
        hold on % 打印一下所有车的编号
        veh_path{i} = plot(vehicles{i}.refpath(:,1),vehicles{i}.refpath(:,2),'k',LineWidth=1);
        % veh_dot{i} = vehicles{i}.show(colorMap{i});
        veh_dot{i} = vehicles{i}.showImg(light_angle);
        veh_text{i} = text(vehicles{i}.pos(1),vehicles{i}.pos(2),num2str(i));
        hold off
    end

    [xlimit,ylimit]=getBoxVisionLimit(vehicles);
    xlim(xlimit)
    ylim(ylimit)
    toc
    pause(0.0001)
    disp(num2str(iters))
end
%% 数据后处理

for i = 1:veh_num
    datalogs{i}.cutBeforeIdx();% 剪裁数据
end

%% 绘图展示结果
figure
%轨迹对比
subplot(3,1,1)
hold on
for i = 1:veh_num
    plot(datalogs{i}.positions(:,1),datalogs{i}.positions(:,2),'LineWidth',1);
end
axis equal


title('实际轨迹与规划轨迹对比');
xlabel('x坐标/m')
ylabel('y坐标/m')
hold off

%速度变化图
subplot(3,1,2)
hold on
for i = 1:veh_num
    plot(datalogs{i}.time,datalogs{i}.velocitys);
end
hold off
title('车速变化图');
xlabel('时间/s')
ylabel('车速/m/s')

%前轮转角图
subplot(3,1,3)
hold on
for i = 1:veh_num
    plot(datalogs{i}.time,datalogs{i}.deltas*180/pi);
end
hold off
title('前轮转角变化');
xlabel('时间/s')
ylabel('转角/°')

