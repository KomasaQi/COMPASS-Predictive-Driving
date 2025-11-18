clc
clear
close all
load dataSet.mat
load obsPre.mat
%% 构建道路场景
%场景初始化
scenario = drivingScenario; %初始化场景
scenario.SampleTime = 0.1; %修改采样时间

%道路中心坐标
roadCenters=[-50,50,0;-50,-50,0;0,0,0;50,50,0;50,-50,0];

%建立道路
marking = [laneMarking('Solid') ...
	laneMarking('Dashed') laneMarking('Solid')]; %分界线线型
laneSpecification = lanespec(2,'Marking',marking);        %道路规范
road(scenario,roadCenters,'Lanes',laneSpecification );    %生成道路

% 获得道路边界，先把便捷点位置重新整理次序
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

%本车信息
ego.vehicle =[];
ego.waypoints = rightWaypoints;
ego.pos=ego.waypoints(1,:);
ego.speed=15;

%1号交通车信息
obs=struct;
obs(1).vehicle=[];
obs(1).waypoints = rightWaypoints(50:end,:);
obs(1).pos=obs(1).waypoints(1,:);
obs(1).speed=10;

%2号交通车信息
obs(2).vehicle=[];
obs(2).waypoints = leftWaypoints(30:end,:);
obs(2).pos=obs(1).waypoints(1,:);
obs(2).speed=8;

%% 在场景中添加车辆
%根据自车信息添加车辆
ego.vehicle = vehicle(scenario,'Position',ego.pos);
trajectory(ego.vehicle,ego.waypoints,ego.speed);

%根据交通车信息添加车辆
for i= 1:length(obs)
    obs(i).vehicle = vehicle(scenario,'Position',obs(i).pos);
    trajectory(obs(i).vehicle,obs(i).waypoints,obs(i).speed);
end

%% 启动仿真
step=1;
time=[];
while advance(scenario)
    time(end+1) = scenario.SimulationTime;
    refinfo_obs1(step,1:2)=scenario.Actors(1,2).Position(1:2);
    refinfo_obs2(step,1:2)=scenario.Actors(1,3).Position(1:2);
    refinfo_obs1(step,3)=scenario.Actors(1,2).Yaw;
    refinfo_obs2(step,3)=scenario.Actors(1,3).Yaw;
    refinfo_obs1(step,4:5)=scenario.Actors(1,2).Velocity(1:2);
    refinfo_obs2(step,4:5)=scenario.Actors(1,3).Velocity(1:2);
    
    egoInfo(step,1:2)=scenario.Actors(1,1).Position(1:2);
    egoInfo(step,3)=scenario.Actors(1,1).Yaw;
    egoInfo(step,4:5)=scenario.Actors(1,1).Velocity(1:2);
    step = step +1;
end

%% Simulink的初始常参数
egoTargetSpd_kph=61.2;
iniEgoPos=egoInfo(1,1:2);
iniEgoHeading=egoInfo(1,3);
iniEgoSpd=egoInfo(4:5);

iniObsPos1=refinfo_obs1(1,1:2);
iniObsHeading1=refinfo_obs1(1,3);
iniObsSpd1=refinfo_obs1(4:5);

iniObsPos2=refinfo_obs2(1,1:2);
iniObsHeading2=refinfo_obs2(1,3);
iniObsSpd2=refinfo_obs2(4:5);

%% 转为时序变量
egoPos=timeseries(egoInfo(:,1:2),time);
egoSpd=timeseries(egoInfo(:,4:5),time);
egoVelocity=zeros(size(egoInfo,1),1);
for i=1:size(egoInfo,1)
egoVelocity(i)=norm(egoInfo(i,4:5));
end
egoAcc=timeseries([0;diff(egoVelocity)],time);
egoJerk=timeseries(zeros(size(time)),time);
obsPos1=timeseries(refinfo_obs1(:,1:2),time);
obsSpd1=timeseries(refinfo_obs1(:,4:5),time);
obsPos2=timeseries(refinfo_obs2(:,1:2),time);
obsSpd2=timeseries(refinfo_obs2(:,4:5),time);
%获得参考航向角
diff_x=diff(egoInfo(:,1));
diff_y=diff(egoInfo(:,2));
refHead = atan2(diff_y,diff_x);
refHead(end+1)=refHead(end);
egoHead=timeseries(refHead,time);
leftWaypoints=[interp1(1:size(leftWaypoints,1),leftWaypoints(:,1),1:0.5:size(leftWaypoints,1),'spline','extrap')',...
    interp1(1:size(leftWaypoints,1),leftWaypoints(:,2),1:0.5:size(leftWaypoints,1),'spline','extrap')'];
leftWaypoints=[leftWaypoints,zeros(size(leftWaypoints,1),1)];
rightWaypoints=[interp1(1:size(rightWaypoints,1),rightWaypoints(:,1),1:0.5:size(rightWaypoints,1),'spline','extrap')',...
    interp1(1:size(rightWaypoints,1),rightWaypoints(:,2),1:0.5:size(rightWaypoints,1),'spline','extrap')'];
rightWaypoints=[rightWaypoints,zeros(size(rightWaypoints,1),1)];


