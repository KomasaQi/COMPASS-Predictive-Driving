clc
% clear
close

%% 相关参数定义
Q=diag([1,1,1]);
R=diag([0.05,0.05]);
rng(0)
kp=10;  %车速控制器参数
ki=2;    %车速控制器参数
kd=1;     %车速控制器参数
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

% 获得参考前轮转角
delta_ref=atan(cur.*L); 
%获得参考航向角
diff_x=diff(path(:,1));
diff_y=diff(path(:,2));
refHead = atan2(diff_y,diff_x);
refHead(end+1)=refHead(end);
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

%初始化仿真变量
idx=0;
iter=0;
while idx<size(path,1)%当目标点的个数大于等于最终点时结束仿真循环
    iter=iter+1;
    %记录车辆状态
    position(iter,:)=pos;
    speed(iter)=spd;
    heading(iter)=head;
    Delta(iter)=delta;

    %获取与位置距离最近的轨迹点
    idx=findTargetIdx(pos,path);
    
    %LQR控制器
    [dv,ddelta]=LQR_ctrl(idx,pos,head,path,refHead(idx),Ts,v_tgt,delta_ref(idx),Q,R,L,spd,delta);
    
    %更新车辆状态
    delta=ddelta+delta;
    delta=sign(delta)*min([abs(delta),30/180*pi]);
    spd=spd+dv;
    pos=pos+(spd*Ts).*[cos(head),sin(head)];
    head=head+spd*Ts*tan(delta)/L;
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

%% 子函数：获取参考轨迹最近的点
function idx=findTargetIdx(pos,path)
dist=zeros(size(path,1),1);
for i=1:size(dist,1)
   dist(i,1)=norm(path(i,1:2)-pos);
end
[~,idx]=min(dist); %找到距离当前位置最近的一个参考轨迹点的序号和距离

end

%% 子函数:LQR控制器
function [dv,ddelta]=LQR_ctrl(idx,pos,head,path,refHead,dt,vref,refDelta,Q,R,L,v,delta)
%求位置、航向角偏差量
ex=pos(1)-path(idx,1);
ey=pos(2)-path(idx,2);
eh=head-refHead;
X=[ex;ey;eh];

%由状态方程系数矩阵，计算K
A=[1,   0,   -vref*dt*sin(refHead);
   0,   1,   vref*dt*cos(refHead);
   0,   0,         1             ];
B=[cos(refHead),          0;
   sin(refHead),          0;
   tan(refDelta)/L,  vref/(L*cos(refDelta)^2)]*dt;

K=RicattiForLQR(A,B,Q,R);
 
%获得前轮速度变化量、前轮转角变化量两个控制量
u=-K*X;  %2×1

%获取相对参考量的控制变化量输出
dv_ref=u(1);
ddelta_ref=u(2);  

%对速度变化量进行变换与限幅
v_tmp=vref+dv_ref;
ddv=v_tmp-v;
dv=sign(ddv)*min([abs(ddv),dt*0.2*9.806]);
%对转角变化量进行变换
delta_tmp=refDelta+ddelta_ref;
ddd=delta_tmp-delta;
ddelta=sign(ddd)*min([abs(ddd),dt*180/180*pi]);
end


function K=RicattiForLQR(A,B,Q,R)
iter_max=500;
P0=Q;
P=zeros(size(Q));
iter=0;
while (max(max(abs(P0-P)))>eps)
    iter=iter+1;
    if iter==iter_max
        break
    end
    P= Q + A'*P0*A - (A'*P0*B)*((R+B'*P0*B)\(B'*P0*A));
    P0=P;
end
K=(B'*P*B + R)\(B'*P*A);

end









