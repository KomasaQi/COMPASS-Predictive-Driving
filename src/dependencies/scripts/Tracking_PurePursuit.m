clc
% clear
close
%% 获得参考轨迹
[path,cur,len]=getSingleLaneChangePath(50,'poly');
rng(0)
%% 相关参数定义
Kv = 0.1; %前视距离系数
Kp = 0.8; %速度P控制器系数
kp=50;  %车速控制器参数
ki=0.5;    %车速控制器参数
kd=5;     %车速控制器参数
Ld0=2;    %预瞄距离下限值
Ts=0.02;   %控制步长，单位：s
L=2.9;    %轴距
v_tgt=17; %目标速度
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
time=(0:Ts:30)';

%车辆初始状态定义
pos=[0,-1.4];
spd=15;
head=0.2;
delta=0; %初始车轮转角

%误差与控制量初始化
e=ones(3,1)*(v_tgt-spd);
ax=0;

%初始化仿真变量
idx_tgt=0;
iter=0;
while idx_tgt<size(path,1)%当目标点的个数大于等于最终点时结束仿真循环
    iter=iter+1;
    %记录车辆状态
    position(iter,:)=pos;
    speed(iter)=spd;
    heading(iter)=head;
    Delta(iter)=delta;
    %获取预瞄距离
    Ld=Ld0+Kv*spd;
    %获取预瞄点
    [AimPoint,idx_tgt]=findAimPoint(pos,path,Ld);
    %获取的车轮转角
    delta=getWheelAngle(pos,AimPoint,head,L,Ld,delta,Ts);
    %获取加速度
    e=[e(2);e(3);v_tgt-spd];
    ax=vxPID(e,ax,kp,ki,kd,Ts);
    %更新车辆状态
    pos=pos+(spd*Ts).*[cos(head),sin(head)] ;
    head=head+spd*Ts*tan(delta)/L ;
    spd=spd+ax*Ts;
    
end
%删除后续未用到的点
position(iter:end,:)=[];
heading(iter:end,:)=[];
speed(iter:end,:)=[];
time(iter:end,:)=[];
Delta(iter:end,:)=[];
%% 绘图展示结果
figure(1)
%轨迹对比
subplot(3,1,1)
plot(path(:,1),path(:,2));
hold on
plot(position(:,1),position(:,2),'r');
title('实际轨迹与规划轨迹对比');
xlabel('x坐标/m')
ylabel('y坐标/m')
hold off

%速度变化图
subplot(3,1,2)
plot(time,speed);
title('车速变化图');
xlabel('时间/s')
ylabel('车速/m/s')

%前轮转角图
subplot(3,1,3)
plot(time,Delta*180/pi);
title('前轮转角变化');
xlabel('时间/s')
ylabel('转角/°')

%换道场景加轨迹对比
drawLaneChange([position,heading],path,time,'comparefigure2')

%% 子函数：获得预瞄点位置和其在path序列上的坐标
function [AimPoint,idx]=findAimPoint(position,path,Ld)
dist=zeros(size(path,1),1);
for i=1:length(dist)
dist(i)=norm(position-path(i,1:2))-Ld;
end
dist_sign=sign(dist);
dist=abs(dist);
idx=find(dist_sign==-1);
if isempty(idx)
    [~,idx]=min(dist);
    idx=idx+100;
    if(idx>size(path,1))
        idx=size(path,1);
    end
end
idx=idx(end);
if idx>=length(dist)
    idx=length(dist)-1;
end
[~,index]=min([dist(idx),dist(idx+1)]);
idx=index+idx-1;
AimPoint=path(idx,1:2);
end

%% 子函数：获取下一时刻的车轮转角
function delta=getWheelAngle(pos,Aimpoint,head,L,Ld,delta0,Ts)
direction=(Aimpoint-pos)/norm(Aimpoint-pos);
alpha=cart2pol(direction(1),direction(2))-head;
delta=atan(2*sin(alpha)*L/Ld);
si=sign(delta);
delta=si*min([abs(delta),30/180*pi]);%限定前轮最大转角30度
ternRateLim=180/180*pi; %限定转动速度180°每秒
if abs((delta-delta0)/Ts)>ternRateLim
    delta=delta0+sign(delta-delta0)*ternRateLim*Ts;
end
end










