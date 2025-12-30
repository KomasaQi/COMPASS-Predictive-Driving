clc
clear 
close all
%% 场景定义
%环岛场景路段与车辆相关参数的定义
d=3.5;        %道路标准宽度
len_lane=60;  %直线段长度
W=1.75;       %车宽
L=3;          %车长
x1=50;        %1号车坐标

% 车辆换道初始状态与重点期望状态
t0=0;
t1=3;
state0=[0,-d/2;17,0;0,0]; % x,y; vx,vy; ax,ay
state1=[50,d/2;17,0;0,0];
x2=state0(1);

%% 画场景示意图
figure(1)
subplot(3,1,1);
%画灰色路面图
GreyZone=[-5,-d-0.5;-5,d+0.5;len_lane,d+0.5;len_lane,-d-0.5];
fill(GreyZone(:,1),GreyZone(:,2),[0.5,0.5,0.5]);
hold on
%画小车
fill([x1,x1,x1+L,x1+L],[-d/2-W/2,-d/2+W/2,-d/2+W/2,-d/2-W/2],'b') %1号车
fill([x2,x2,x2+L,x2+L],[-d/2-W/2,-d/2+W/2,-d/2+W/2,-d/2-W/2],'y') %2号车
%画车道线
plot([-5,len_lane],[0,0],'w--','linewidth',2); %分界线
plot([-5,len_lane],[d,d],'w','linewidth',2); %左边界线
plot([-5,len_lane],[-d,-d],'w','linewidth',2); %右边界线
%设置坐标轴显示范围
axis equal
set(gca,'XLim',[-5,len_lane]);
set(gca,'YLim',[-4,4]);

%% 五次多项式轨迹生成
%计算A和B两个系数矩阵
X=[state0(:,1);state1(:,1)];
Y=[state0(:,2);state1(:,2)];
T=[...
    t0^5     t0^4     t0^3     t0^2     t0      1;
    5*t0^4   4*t0^3   3*t0^2   2*t0     1       0;
    20*t0^3  12*t0^2  6*t0     2        0       0;
    t1^5     t1^4     t1^3     t1^2     t1      1;
    5*t1^4   4*t1^3   3*t1^2   2*t1     1       0;
    20*t1^3  12*t1^2  6*t1     2        0       0;
    ];
A= T \ X;
B= T \ Y;

%将时间从t0到t1离散化，获得离散时刻的轨迹坐标
Ts=0.05;
t=(0:Ts:t1)';
path=zeros(length(t),6); %1-6列分别存放x,y,vx,vy,ax,ay
for i=1:length(t)
   %横向位置坐标
   path(i,1)=[t(i)^5,t(i)^4,t(i)^3,t(i)^2,t(i),1]*A;
   %纵向位置坐标
   path(i,2)=[t(i)^5,t(i)^4,t(i)^3,t(i)^2,t(i),1]*B;
   %横向速度
   path(i,3)=[5*t(i)^4,4*t(i)^3,3*t(i)^2,2*t(i),1,0]*A;
   %纵向速度
   path(i,4)=[5*t(i)^4,4*t(i)^3,3*t(i)^2,2*t(i),1,0]*B;
   %横向加速度
   path(i,5)=[20*t(i)^3,12*t(i)^2,6*t(i),2,0,0]*A;
   %纵向加速度
   path(i,6)=[20*t(i)^3,12*t(i)^2,6*t(i),2,0,0]*B;
   
end

%% 画换道轨迹
plot(path(:,1),path(:,2),'r--','linewidth',1.5);
hold off

%分析速度
subplot(3,1,2);
plot(t,path(:,[3 4])*3.6);
legend('x方向速度vx','y方向速度vy');
xlabel('时间/s');
ylabel('速度分量/ km/h');

%分析加速度
subplot(3,1,3);
plot(t,path(:,[5 6])/9.806);
legend('x方向加速度ax','y方向加速度ay');
xlabel('时间/s');
ylabel('加速度分量/g');



