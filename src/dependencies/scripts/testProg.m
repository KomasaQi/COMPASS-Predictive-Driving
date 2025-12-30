%如果还没仿真，使用以下数据集进行展示
%如果需要用刚刚仿真的数据，请注释load这一行，不用加载旧数据
load SimOut20230305.mat out
%% 绘制仿真结果动画
%定义仿真场景
scenarioSim = drivingScenario; %初始化场景
scenarioSim.SampleTime = 0.02; %修改采样时间
%道路中心坐标
roadCenters=[-50,50,0;-50,-50,0;0,0,0;50,50,0;50,-50,0];

%建立道路
marking = [laneMarking('Solid') ...
	laneMarking('Dashed') laneMarking('Solid')]; %分界线线型
laneSpecification = lanespec(2,'Marking',marking);        %道路规范
road(scenarioSim,roadCenters,'Lanes',laneSpecification );    %生成道路
%% 构建车辆信息
%本车信息
ego.vehicle =[];
posx=reshape(out.position.Data(1,1,:),length(out.tout),1);
posy=reshape(out.position.Data(1,2,:),length(out.tout),1);
ego.waypoints = [posx,posy,zeros(size(posx))];
ego.pos=ego.waypoints(1,:);
ego.speed=out.spdcmd.data;

%1号交通车信息
obs=struct;
obs(1).vehicle=[];
obs(1).waypoints = [out.obscar1pos.data,zeros(length(out.tout),1)];
obs(1).pos=obs(1).waypoints(1,:);
obs(1).speed=10;

%2号交通车信息
obs(2).vehicle=[];
obs(2).waypoints = [out.obscar2pos.data,zeros(length(out.tout),1)];
obs(2).pos=obs(1).waypoints(1,:);
obs(2).speed=8;
%% 在场景中添加车辆
%根据自车信息添加车辆
ego.vehicle = vehicle(scenarioSim,'Position',ego.pos);
trajectory(ego.vehicle,ego.waypoints,ego.speed);

%根据交通车信息添加车辆
for i= 1:length(obs)
    obs(i).vehicle = vehicle(scenarioSim,'Position',obs(i).pos);
    trajectory(obs(i).vehicle,obs(i).waypoints,obs(i).speed);
end
restart(scenarioSim);
plot(scenarioSim);
title('自动驾驶车辆预测-决策-规划-控制仿真')
hold on
path_egox=out.allpath.Data(:,1,:);
path_egoy=out.allpath.Data(:,2,:);
i=0;
while advance(scenarioSim)
    i=i+1;
    path_obs1pre=out.preTraj_real1.data(:,:,i);
    path_obs2pre=out.preTraj_real2.data(:,:,i);
    path_ego=plot(path_egox(:,1,i),path_egoy(:,1,i),'b');
    path_obs1=plot(path_obs1pre(:,1),path_obs1pre(:,2),'g');
    path_obs2=plot(path_obs2pre(:,1),path_obs2pre(:,2),'g');

    
    
    
    pause(0.01)
    delete(path_ego)
    delete(path_obs1)
    delete(path_obs2)
  
    
end
hold off




%% 下面的部分是绘制车辆动图用的哦

x=out.allpath.Data(:,1,:);
y=out.allpath.Data(:,2,:);
posx=reshape(out.position.Data(1,1,:),length(out.tout),1);
posy=reshape(out.position.Data(1,2,:),length(out.tout),1);
head=out.heading.data;
%环岛场景路段与车辆相关参数的定义
W=1.75;       %车宽
L=3;          %车长
figure(2)
hold on
axis equal
plot(posx,posy)
for i=1:length(out.tout)
    
    
    path_ego=plot(x(:,1,i),y(:,1,i));
    x2=posx(i);
    y2=posy(i);
    f2=head(i);
    [xcar2,ycar2]=RotatePolygon([x2,x2,x2+L,x2+L],[y2-W/2,y2+W/2,y2+W/2,y2-W/2],[x2,y2],f2);
    filledzone=fill(xcar2,ycar2,'y'); %2号车
    pause(0.01)
    delete(filledzone)
    delete(path_ego)
    
end
hold off





%% 下面是绘制DP QP规划过程用的哟
routedpx=out.route.Data(:,1,:);
routedpy=out.route.Data(:,2,:);
routeqpx=out.routeqp.Data(:,1,:);
routeqpy=out.routeqp.Data(:,2,:);
figure(3)
hold on
for i=1:length(out.tout)
    obs1=out.obs1.Data(:,:,i);
    obs2=out.obs2.Data(:,:,i);
    clearList=[];
    for j=1:size(obs1,1)
        if isinf(obs1(j,2))
            clearList=[clearList,j];
        end
    end
    differ=setdiff(1:size(obs1,1),clearList);
    obs1=obs1(differ,:);
    
    clearList=[];
    for j=1:size(obs2,1)
        if isinf(obs2(j,2))
            clearList=[clearList,j];
        end
    end
    differ=setdiff(1:size(obs2,1),clearList);
    obs2=obs2(differ,:);
    
    obsZone1=[obs1(:,[1 2]);obs1(end:-1:1,1),obs1(end:-1:1,3)];
    obsZone2=[obs2(:,[1 2]);obs2(end:-1:1,1),obs2(end:-1:1,3)];
    z1=fill(obsZone1(:,1),obsZone1(:,2),'b');
    z2=fill(obsZone2(:,1),obsZone2(:,2),'b');
    routedp=plot(routedpx(:,1,i),routedpy(:,1,i),'b');
    routeqp=plot(routeqpx(:,1,i),routeqpy(:,1,i),'g');
    
    pause(0.05)
    delete(z1)
    delete(z2)
    delete(routeqp)
    delete(routedp)
end
hold off

%% 绘制横向误差
figure
plot(out.tout,out.ey.Data)
title('轨迹跟踪横向误差')
xlabel('时间/s');
ylabel('横向误差ey/m')
%% 保存仿真结果
save SimOut20230305.mat out



