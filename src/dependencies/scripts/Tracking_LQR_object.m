clc
% clear
% close

%% 相关参数定义

ctrller = LQR_TrackingController();
idm = IDM();
idm.v_des = 17;%目标速度
idm.delta = 20;
Ts = 0.02;   %控制步长，单位：s
ctrller.Ts = Ts;
L = 2.9;    %轴距
ctrller.L = L;
ctrller.R = diag([0.05,0.1]);
x_road_dim = (0:0.1:50)';
Road.Lanes{1}=[x_road_dim,-1.75*ones(size(x_road_dim))];
Road.Lanes{2}=[x_road_dim,1.75*ones(size(x_road_dim))];
Road.LaneNum = length(Road.Lanes);

pathname='SLC';%轨迹可选为单移线'SLC'或S型'S'
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
position=zeros(size(path,1),2);
speed=zeros(size(path,1),1); 
heading=zeros(size(path,1),1); %航向角
Delta=zeros(size(path,1),1); %前轮转角
lat_err = zeros(size(path,1),1); 
time=(0:Ts:30)';

%车辆初始状态定义
% pos=[0,-1.4];
pos=[10,1.75];
spd=15;
head=0.1;
delta=0; %初始车轮转角

%初始化仿真变量
idx=0;
iter=0;
while idx<size(path,1)%当目标点的个数大于等于最终点时结束仿真循环
    [~,idx,dev]=findTargetIdxDev(pos,path);   
    iter=iter+1;
    %记录车辆状态
    position(iter,:)=pos;
    speed(iter)=spd;
    heading(iter)=head;
    Delta(iter)=delta;
    lat_err(iter)=dev;
    %LQR控制器
    
    ddelta=ctrller.LQR_ctrl(pos,head,path,spd,delta);

    %更新车辆状态
    delta=ddelta+delta;
    delta=sign(delta)*min([abs(delta),15/180*pi]);
    dv = idm.acc(spd,100,100);
    spd = spd+dv*Ts;
    pos=pos+(spd*Ts).*[cos(head),sin(head)];
    head=head+spd*Ts*tan(delta)/L;
end

%删除后续未用到的点
position(iter:end,:)=[];
heading(iter:end,:)=[];
speed(iter:end,:)=[];
time(iter:end,:)=[];
Delta(iter:end,:)=[];
lat_err(iter:end,:)=[];
%% 绘图展示结果
figure(1)
%轨迹对比
subplot(4,1,1)
plot(path(:,1),path(:,2));
axis equal
hold on
plot(position(:,1),position(:,2),'r');
for i = 1:Road.LaneNum
    plot(Road.Lanes{i}(:,1),Road.Lanes{i}(:,2),'k');
end
title('实际轨迹与规划轨迹对比');
xlabel('x坐标/m')
ylabel('y坐标/m')
hold off

%速度变化图
subplot(4,1,2)
plot(time,speed);
title('车速变化图');
xlabel('时间/s')
ylabel('车速/m/s')

%前轮转角图
subplot(4,1,3)
plot(time,Delta*180/pi);
title('前轮转角变化');
xlabel('时间/s')
ylabel('转角/°')

%跟踪误差图
subplot(4,1,4)
plot(time,lat_err);
title('跟踪误差');
xlabel('时间/s')
ylabel('横向跟踪误差/m')

%换道场景加轨迹对比
drawLaneChange([position,heading],path,time,'comparefigure2')










