%B代表Bezier
clc
clear
close all
%% 定义换道场景
d=3.5;
state0=[0,-d/2;17,0;0,0];
state1=[50,d/2;17,0;0,0];
tspan=[0,3];
Ts=0.01;
%% 求解B样条曲线
[path,t,cv]=bsplinepath(state0,state1,tspan,Ts);
%求解轨迹曲率
cur=curvature(path(:,1),path(:,2));
distance=xy2distance(path(:,1),path(:,2));

%% 绘图
drawLaneChange(path,t,'not analyze');
% 绘制控制点
hold on
scatter(cv(:,1),cv(:,2));
plot(cv(:,1),cv(:,2),'g','linewidth',0.1);
hold off
%绘制轨迹曲率变化
figure
plot(distance,cur)
title('轨迹曲率');
xlabel('路程/m');
ylabel('曲率/ 1/m');