%% 第一节 基于车道线方程的曲率计算
clc
clear 
close all
%% 构建道路场景
scenario=drivingScenario; %初始化场景
scenario.SampleTime=0.1; % 采样时间

%道路中心坐标
roadCenters=[0 0 0;2 0 0;4 0 0;30 -15 0;60 -40 0];

%建立道路   ↓分界线线型
marking=[laneMarking('Solid'),...
    laneMarking('Dashed'),  laneMarking('Dashed'), laneMarking('Solid')];
laneSpecification = lanespec(3,'Marking',marking); %道路规范
road(scenario,roadCenters,'Lane',laneSpecification);%生成道路



%% 构建车辆信息
%分别三条车道线的中心线坐标，以生成车辆航迹点
[waypoints,lanepoints]=getWaypoints(scenario,3);


%本车信息
ego.vehicle =[];
ego.waypoints = waypoints{2};
ego.pos=ego.waypoints(1,:);
ego.speed=15;

%1号交通车信息
obs=struct;
obs(1).vehicle=[];
obs(1).waypoints = waypoints{1}(5:end,:);
obs(1).pos=obs(1).waypoints(1,:);
obs(1).speed=10;

%2号交通车信息
obs(2).vehicle=[];
obs(2).waypoints =  waypoints{2}(10:end,:);
obs(2).pos=obs(2).waypoints(1,:);
obs(2).speed=13;

%2号交通车信息
obs(3).vehicle=[];
obs(3).waypoints = waypoints{3}(12:end,:);
obs(3).pos=obs(3).waypoints(1,:);
obs(3).speed=8;

%% 在场景中添加车辆
%根据自车信息添加车辆
ego.vehicle = vehicle(scenario,'Position',ego.pos);
trajectory(ego.vehicle,ego.waypoints,ego.speed);

%根据交通车信息添加车辆
for i= 1:length(obs)
    obs(i).vehicle = vehicle(scenario,'Position',obs(i).pos);
    trajectory(obs(i).vehicle,obs(i).waypoints,obs(i).speed);
end
restart(scenario)
plot(scenario)
hold on
% chasePlot(ego.vehicle)
pause(1);
while advance(scenario)
pause(0.05);
end
%% 获得主车轨迹
% rec=record(scenario);
% time=zeros(length(rec),1);
% traj=zeros(length(rec),3);
% for i=1:length(rec)
%     time(i)=rec(i).SimulationTime;
%     [traj(i,:),~,~,~]=rec(i).ActorPoses.Position;
% end
%% 利用三次多项式对车道线进行拟合
%拟合得到双侧车道线和车道中心线的三次多项式系数
centx=mean([(lanepoints{3}(:,1)');(lanepoints{2}(:,1)')]);
centy=mean([(lanepoints{3}(:,2)');(lanepoints{2}(:,2)')]);

pleft=polyfit(lanepoints{2}(:,1),lanepoints{2}(:,2),3);
pright=polyfit(lanepoints{3}(:,1),lanepoints{3}(:,2),3);
pcent=polyfit(centx,centy,3);

fleft=polyval(pleft,lanepoints{2}(:,1));
fright=polyval(pright,lanepoints{3}(:,1));
fcent=polyval(pcent,centx);

dy=polyval(pcent(1:3).*[3 2 1],centx);
ddy=polyval(pcent(1:2).*[6 2],centx);
cur=ddy./(1+dy.^2).^(3/2);
len=xy2distance(centx,fcent);
cur2=curvature(centx,fcent);
cur3=curvature(interp1(1:length(centx),centx,1:0.2:length(centx),'spline','extrap'),...
    interp1(1:length(centy),centy,1:0.2:length(centy),'spline','extrap'));
len3=xy2distance(interp1(1:length(centx),centx,1:0.2:length(centx),'spline','extrap'),...
    interp1(1:length(centy),centy,1:0.2:length(centy),'spline','extrap'));
%% 画图展示结果
% fcent=polyval(mean([pright;pright]),mean([(lanepoints{3}(:,1)');(lanepoints{2}(:,1)')]));
restart(scenario);
plot(lanepoints{2}(:,1),fleft,'b--',lanepoints{3}(:,1),fright,'b--',centx,fcent,'b');
figure(2)
plot(len,cur,len3,cur3)
legend('拟合的3次多项式','实际道路')
title('根据三次曲线求出的车道线曲率')
xlabel('路程/m')
ylabel('曲率/(1/m)')

















function [waypoints,lanepoints]=getWaypoints(scenario,laneNum)
%获得道路边界，先把边界点位置重新整理次序
rdbdy=roadBoundaries(scenario);
rdbdy=rdbdy{1}(1:end-1,:);
rdbdy=[rdbdy(3:end,:);rdbdy(1:2,:)];
right=rdbdy(1:end/2,:);
left=rdbdy(end:-1:end/2+1,:);
waypoints=cell(laneNum,1);
lanepoints=cell(laneNum+1,1);
for i=1:laneNum+1
    if i<=laneNum
    waypoints{i}=left+(right-left)*i/(laneNum+1);
    end
    lanepoints{i}=left+(right-left)*(i-1)/laneNum;
end
end



