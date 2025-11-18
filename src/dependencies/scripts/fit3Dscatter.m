clc
close all 
clear
%% 定义空间散点
cv=[0 5 3;
    1 2 4;
    2 3 5;
    3 4 2;
    4 1 0];
%% 拟合曲线
path=fit3Dcurve(cv,[0 1],0.001,'showcurve');
%% 求曲率挠率
[cur,tor]=curvature3(path(:,1),path(:,2),path(:,3));
%% 画图展示结果
len=xyz2distance(path(:,1),path(:,2),path(:,3));
figure(2)
plot(len,cur,len,tor);
title('空间拟合曲线的曲率和挠率')
xlabel('曲线长度')
ylabel('曲率、挠率/（1/m）')
legend('curvature','torsion')

