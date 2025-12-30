clc
% clear
close

%% 相关参数定义
System_Ts = 0.02;
% 定义车辆1
initpos.delta = 0;
initpos.pos = [0,1.75];
initpos.head = 0.1;
initpos.spd = 0;
initpos.acc = 0;
veh_params.L = 2.9;
ctrller_params.Ts = System_Ts;
cons_params.delta_max = 15/180*pi;

vehicles{1} = Vehicle_LQR_IDM(initpos,veh_params,ctrller_params,cons_params);
vehicles{1}.longictrller.v_des = 17;
vehicles{1}.longictrller.delta = 4;
vehicles{1}.latctrller.R = diag([0.05,0.5]);

% 定义车辆2
initpos.pos = [0,-1.70];
initpos.head = -0.1;
initpos.spd = 0;

vehicles{2} = Vehicle_LQR_IDM(initpos,veh_params,ctrller_params,cons_params);
vehicles{2}.longictrller.v_des = 20;
vehicles{2}.longictrller.delta = 5;
vehicles{2}.latctrller.R = diag([0.05,0.3]);

vehicle_num = 2;

%% 定义数据记录
tspan_max = [0,50];
datalogs{1} = Vehicle_Dataloger(tspan_max,System_Ts);
datalogs{2} = Vehicle_Dataloger(tspan_max,System_Ts);

%% 定义道路
x_road_dim = (0:0.1:50)';
Road.Lanes{1}=[x_road_dim,-1.75*ones(size(x_road_dim))];
Road.Lanes{2}=[x_road_dim,1.75*ones(size(x_road_dim))];
Road.LaneNum = length(Road.Lanes);

pathname='S';%轨迹可选为单移线'SLC'或S型'S'
%% 获得参考轨迹
if strcmp(pathname,'SLC')
    [path,cur,len]=getSingleLaneChangePath(50,'poly');
elseif strcmp(pathname,'S')
    load S_path.mat;
    cur=curvature(path(:,1),path(:,2));
    len=xy2distance(path(:,1),path(:,2));
else
    disp('请输入合法的换道轨迹名称呀');
end

%% 主程序

% 车辆状态空间定义


v_des = [17,20];
refpath ={path,path};
%初始化仿真变量
posx_max=0;
iter=0;
while posx_max<130%当目标点的个数大于等于最终点时结束仿真循环
    if vehicles{2}.pos(1)>100
        v_des(2) = 10;
    else
        v_des(2) = 20;
    end
    iter=iter+1;
    
    for carNum = 1:vehicle_num
        % 记录车辆状态
        datalogs{carNum} = datalogs{carNum}.logData(vehicles{carNum});
    end
    %LQR控制器
    for carNum = 1:vehicle_num
        dev = inf;
        inter_veh_eql_dist = inf;
        front_vehicle_num = [];
        for num = 1:vehicle_num % 从所有车中找出离自己最近的前车
            if num == carNum % 把自己跳过去
                continue
            end
            dist_temp = InterVehEqlDist(vehicles{carNum}.pos,...
                vehicles{carNum}.head,vehicles{carNum}.L,vehicles{num}.pos,vehicles{num}.L);
            if dist_temp < 0 % 如果这辆车在自己后面,就不要管了
                continue
            end
            if inter_veh_eql_dist < dist_temp % 如果有其他前车比自己更近，也不用管了
                continue
            else 
                inter_veh_eql_dist = dist_temp;
                front_vehicle_num = num;
            end
        end
        if ~isempty(front_vehicle_num)
            [~,~,dev]=findTargetIdxDev(vehicles{front_vehicle_num}.pos,refpath{carNum});
        end
         
        if vehicles{carNum}.pos(1)> posx_max % 更新迭代终止条件
            posx_max = vehicles{carNum}.pos(1);
        end
        if dev < 2.2
            vehicles{carNum} = vehicles{carNum}.step(refpath{carNum},v_des(carNum),vehicles{front_vehicle_num});
        else
            vehicles{carNum} = vehicles{carNum}.step(refpath{carNum},v_des(carNum),[]);
        end
    end


end

%删除后续未用到的点
for carNum = 1:2
    datalogs{carNum} = datalogs{carNum}.cutBeforeIdx(iter+1);
end
%% 绘图展示结果
figure(1)
%轨迹对比
subplot(3,1,1)
hold on
for carNum = 1:2
    plot(datalogs{carNum}.positions(:,1),datalogs{carNum}.positions(:,2),'LineWidth',1);
end
plot(path(:,1),path(:,2),'k');
axis equal
for i = 1:Road.LaneNum
    plot(Road.Lanes{i}(:,1),Road.Lanes{i}(:,2),'k');
end

title('实际轨迹与规划轨迹对比');
xlabel('x坐标/m')
ylabel('y坐标/m')
hold off

%速度变化图
subplot(3,1,2)
hold on
for carNum = 1:2
    plot(datalogs{carNum}.time,datalogs{carNum}.velocitys);
end
hold off
title('车速变化图');
xlabel('时间/s')
ylabel('车速/m/s')

%前轮转角图
subplot(3,1,3)
hold on
for carNum = 1:2
    plot(datalogs{carNum}.time,datalogs{carNum}.deltas*180/pi);
end
hold off
title('前轮转角变化');
xlabel('时间/s')
ylabel('转角/°')


% %换道场景加轨迹对比
% 
% drawLaneChange([position,heading],path,time,'comparefigure2')

scenario = drivingScenario('SampleTime',0.02);
roadcenters = path(1:10:end,:);
roadcenters = offset2DCurve(roadcenters,1.75,[0,1]);
lspec = lanespec(2);
%建立道路
marking = [laneMarking('Solid') ...
	laneMarking('Dashed') laneMarking('Solid')];          %分界线线型
laneSpecification = lanespec(2,'Marking',marking);        %道路规范
road(scenario,roadcenters,'Lanes',laneSpecification );    %生成道路

% 获得道路边界，先把边界点位置重新整理次序
rdbdy = roadBoundaries(scenario);
rdbdy=rdbdy{1,1}(1:end-1,:);
rdbdy=[rdbdy(3:end,:);rdbdy([1 2],:)];

%% 构建车辆信息
%根据单向两车道约定，分别计算左车道和右车道的中心线坐标，以生成车辆航迹点
ptNums= size(rdbdy,1);
leftWaypoints=zeros(ptNums/2,size(rdbdy,2));
rightWaypoints=zeros(size(leftWaypoints));
for j =1:ptNums/2
   rightBdyPt = rdbdy(j,:) ;
   leftBdyPt=rdbdy(ptNums+1-j,:);
   leftWaypoints(j,:)=leftBdyPt+(rightBdyPt-leftBdyPt)*0.25;
   rightWaypoints(j,:)=leftBdyPt+(rightBdyPt-leftBdyPt)*0.75;
end  

v{1} = vehicle(scenario,'ClassID',1);
trajectory(v{1},datalogs{1}.positions,datalogs{1}.velocitys)

v{2} = vehicle(scenario,'ClassID',1);
trajectory(v{2},datalogs{2}.positions,datalogs{2}.velocitys)


chasePlot(scenario.Actors(1))
plot(scenario,'Waypoints','off','RoadCenters','off')
pause(3)
while advance(scenario)
    pause(0.005)
end








