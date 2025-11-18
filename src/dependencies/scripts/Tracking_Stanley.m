clc
% clear
close

%% 相关参数定义
Kv = 0.15; %前视距离系数
Ld0=2;    %预瞄距离下限值
kp=50;  %车速控制器参数
ki=0.5;    %车速控制器参数
kd=5;     %车速控制器参数
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
    d=Kv*spd;
    %获取预瞄点
    idx_tgt=findTargetIdx(pos,path);
    %获取前轮转角：控制量
    delta=getDelta1(idx_tgt,path,d,head,delta,Ts,pos);
    %获取加速度
    e=[e(2);e(3);v_tgt-spd];
    ax=vxPID(e,ax,kp,ki,kd,Ts);
    %更新车辆状态
    pos=pos+(spd*Ts).*[cos(head),sin(head)];
    head=head+spd*Ts*tan(delta)/L;
    spd=spd+ax*Ts;
%     disp(num2str(iter))
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


%% 子函数：获取下一时刻的车轮转角
function delta=getDelta1(idx_tgt,path,d,head,delta0,Ts,pos)
idx=idx_tgt;
if idx==size(path,1)
    idx=idx-1;
elseif idx==1
    idx=2;
end
diff1=path(idx+1,1:2)-path(idx-1,1:2);
direction0=diff1/norm(diff1);
%参考百度Apollo计算横向误差
dx=pos(1)-path(idx_tgt,1);
dy=pos(2)-path(idx_tgt,2);
refHead=cart2pol(direction0(1),direction0(2));
ey=dx*sin(refHead)-dy*cos(refHead);
%分别计算只考虑航向误差和横向误差的theta
theta_y=atan2(ey,d);
theta_fai=refHead-head;
delta=theta_y+theta_fai;

%输出限幅
si=sign(delta);
delta=si*min([abs(delta),30/180*pi]);%限定前轮最大转角30度
ternRateLim=180/180*pi; %限定转动速度180°每秒
if abs((delta-delta0)/Ts)>ternRateLim
    delta=delta0+sign(delta-delta0)*ternRateLim*Ts;
end

end








