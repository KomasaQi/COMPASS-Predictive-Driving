function drawLaneChange(path,refpath,t,option)
%% 场景定义
%环岛场景路段与车辆相关参数的定义
d=3.5;        %道路标准宽度
len_lane=path(end,1)+10;  %直线段长度
W=1.75;       %车宽
L=3;          %车长
x1=path(end,1);        %1号车坐标
y1=path(1,2);

% 车辆换道初始状态与终点期望状态
x2=path(1,1);
y2=path(1,2);
f2=path(1,3);
%% 画场景示意图
if strcmp(option,'comparefigure2')
    figure(2)
else
    figure
end
if strcmp(option,'analyze')
subplot(3,1,1);
end
%画灰色路面图
GreyZone=[-5,-d-0.5;-5,d+0.5;len_lane,d+0.5;len_lane,-d-0.5];
fill(GreyZone(:,1),GreyZone(:,2),[0.5,0.5,0.5]);
hold on
%画小车
fill([x1,x1,x1+L,x1+L],[y1-W/2,y1+W/2,y1+W/2,y1-W/2],'b') %1号车
[xcar2,ycar2]=RotatePolygon([x2,x2,x2+L,x2+L],[y2-W/2,y2+W/2,y2+W/2,y2-W/2],[x2,y2],f2);
fill(xcar2,ycar2,'y') %2号车
%画车道线
plot([-5,len_lane],[0,0],'w--','linewidth',2); %分界线
plot([-5,len_lane],[d,d],'w','linewidth',2); %左边界线
plot([-5,len_lane],[-d,-d],'w','linewidth',2); %右边界线
%设置坐标轴显示范围
axis equal
set(gca,'XLim',[-5,len_lane]);
set(gca,'YLim',[-d-0.5,d+0.5]);
%% 画换道轨迹
plot(path(:,1),path(:,2),'r--','linewidth',1.5);
if strcmp(option,'compare') || strcmp(option,'comparefigure2')
plot(refpath(:,1),refpath(:,2),'b--','linewidth',1);
end
hold off

if strcmp(option,'analyze')
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
end
end

function [x1,y1]=RotatePolygon(x,y,center,th)
pointNum=length(x);
if length(x)~=length(y)
    disp('顶点x,y坐标不一致，请检查一下')
end
x1=zeros(size(x));
y1=zeros(size(y));
for i=1:pointNum
    xc=x(i)-center(1);
    yc=y(i)-center(2);
    x1(i)=(xc*cos(th)-yc*sin(th))+center(1);
    y1(i)=(xc*sin(th)+yc*cos(th))+center(2);
end

end
