clc
clear
close all

%% 加载地图数据
load Map3D001.mat map

%% 给定优化信息
%定义起点和终点
startpoint=[0,0,10];
endpoint=[70,100,20];
%适应度函数可选择：'curandlen','cur','len'
fitnessfcn='curandlen'; %适应度函数为：曲率挠率+长度
cvNum=3;     %中间控制点个数
algo='fminsearch';   %选择非线性最优化算法，'pso','ga','fmincon','fminsearch'
%% 进行优化
tic
[path,cv]=PSObestRoute(map,startpoint,endpoint,cvNum,fitnessfcn,algo);
toc
%% 优化完成，绘图展示结果
% 绘制地图信息
figure
surf(map.x,map.y,map.z);
axis equal
xlabel('x坐标/m');
ylabel('y坐标/m');
zlabel('z坐标/m');
shading flat
hold on
plot3(path(:,1),path(:,2),path(:,3),'r','linewidth',2);
grid on
title('散点拟合曲线')
scatter3(cv(1,1),cv(1,2),cv(1,3),100,'bs','markerfacecolor','y');
scatter3(cv(2:end-1,1),cv(2:end-1,2),cv(2:end-1,3),100,'bs','markerfacecolor','g');
scatter3(cv(end,1),cv(end,2),cv(end,3),100,'bs','markerfacecolor','r');
legend('3D地图','拟合曲线','给定起点','控制点','给定终点')
view(130,30)
hold off

%% 保存结果
save bestRoute3D.mat cv path map






