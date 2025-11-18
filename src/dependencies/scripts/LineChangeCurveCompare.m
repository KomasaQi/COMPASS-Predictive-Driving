clc
clear
close  all
%% 初始化数据
d=3.5;      %道路标准宽度
startPt=[0,-d/2]; %换道点
endPt=[50,d/2]; %换道完成点
state0=[startPt;17,0;0,0];
state1=[endPt;17,0;0,0];
tspan=[0,3];
Ts=0.01;
%% Dubins曲线
A=startPt;
F=endPt;
vA=[1,0];
vF=[1,0];
rmin=150;    %最小转弯半径    
path_dubins=dubins(A,F,vA,vF,rmin,'notplot');  %求Dubins曲线轨迹线
cur_dubins=curvature(path_dubins(:,1),path_dubins(:,2));%求轨迹曲率
len_dubins=xy2distance(path_dubins(:,1),path_dubins(:,2));%获得路程序列

%% 正余弦曲线
omega = pi/(endPt(1)-startPt(1));
x=(startPt(1):0.1:endPt(1))';
y=d/2*sin(omega*(x-(startPt(1)+endPt(1))/2));
path_sin = [x,y];
cur_sin=curvature(path_sin(:,1),path_sin(:,2));
len_sin=xy2distance(path_sin(:,1),path_sin(:,2));

%% 贝塞尔曲线
[path_bezier,~,~]=bezierpath(state0,state1,tspan,Ts);
cur_bezier=curvature(path_bezier(:,1),path_bezier(:,2));
len_bezier=xy2distance(path_bezier(:,1),path_bezier(:,2));

%% B样条曲线
[path_bspline,~,~]=bsplinepath(state0,state1,tspan,Ts);
cur_bspline=curvature(path_bspline(:,1),path_bspline(:,2));
len_bspline=xy2distance(path_bspline(:,1),path_bspline(:,2));

%% 五次多项式
[path_poly,~]=polypath(state0,state1,tspan,Ts);
cur_poly=curvature(path_poly(:,1),path_poly(:,2));
len_poly=xy2distance(path_poly(:,1),path_poly(:,2));

%% 画图比较
% 轨迹曲线
figure(1)
subplot(2,1,1);
hold on
plot(path_dubins(:,1),path_dubins(:,2));
plot(path_sin(:,1),path_sin(:,2));
plot(path_bezier(:,1),path_bezier(:,2));
plot(path_bspline(:,1),path_bspline(:,2));
plot(path_poly(:,1),path_poly(:,2));
title('换道轨迹比较');
xlabel('x坐标/m');
ylabel('y坐标/m');
legend('dubins','sin','Bezier','Bspline','polynomial');
hold off

subplot(2,1,2);
hold on
plot(len_dubins,cur_dubins);
plot(len_sin,cur_sin);
plot(len_bezier,cur_bezier);
plot(len_bspline,cur_bspline);
plot(len_poly,cur_poly);
title('换道曲率比较');
xlabel('路程长度/m');
ylabel('轨迹曲率/(1/m)');
legend('dubins','sin','Bezier','Bspline','polynomial');
axis([0,52,-0.015,0.015])
hold off


















