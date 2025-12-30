%利用本函数获得单移线参考轨迹曲线数据，输入换道终点距离，输入方法即可
function [path,cur,len]=getSingleLaneChangePath(lane_len,method)

%% 初始化数据
d=3.5;      %道路标准宽度
startPt=[0,-d/2]; %换道点
endPt=[lane_len,d/2]; %换道完成点
state0=[startPt;17,0;0,0];
state1=[endPt;17,0;0,0];
tspan=[0,3];
Ts=0.01;
if strcmp(method,'dubins')
%% Dubins曲线
A=startPt;
F=endPt;
vA=[1,0];
vF=[1,0];
rmin=150;    %最小转弯半径    
path=dubins(A,F,vA,vF,rmin,'notplot');  %求Dubins曲线轨迹线
elseif strcmp(method,'sine')
%% 正余弦曲线
omega = pi/(endPt(1)-startPt(1));
x=(startPt(1):0.1:endPt(1))';
y=d/2*sin(omega*(x-(startPt(1)+endPt(1))/2));
path = [x,y];
elseif strcmp(method,'bezier')
%% 贝塞尔曲线
[path,~,~]=bezierpath(state0,state1,tspan,Ts);
elseif strcmp(method,'bspline')
%% B样条曲线
[path,~,~]=bsplinepath(state0,state1,tspan,Ts);
elseif strcmp(method,'poly')
%% 五次多项式
[path,~]=polypath(state0,state1,tspan,Ts);
else
    disp(['输入方法名称有误，请检查一下呀']);
end
cur=curvature(path(:,1),path(:,2));
len=xy2distance(path(:,1),path(:,2));
end