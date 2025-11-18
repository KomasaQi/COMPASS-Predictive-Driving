clc
clear
close all
load Senario.mat
load optPath.mat

%% 参数初始化

%获得障碍车轨迹
startIdx=135;
endIdx=210;
obsPath=zeros(length(startIdx:endIdx),2);
for i=1:length(obsPath)
   obsPath(i,:) =tjty(i-1+startIdx).pos;
end

%画场景图
plot(scenario);
hold on
plot(path_opt(:,1),path_opt(:,2),'r','linewidth',1.5);  
plot(obsPath(:,1),obsPath(:,2),'b--','linewidth',1.5); 

%计算障碍车每个轨迹点的航向角
diffX=diff(obsPath(:,1));
diffY=diff(obsPath(:,2));
ptNum=size(obsPath,1);
heading=atan2(diffY,diffX);
heading(end+1)=heading(end);

%% 将障碍车轨迹映射到ST图
S_lb=[];
S_ub=[];
for i=1:ptNum
   t=i*scenario.SampleTime;
   
   %车尾中心点位置和车辆航向角
   rearPosX=obsPath(i,1);
   rearPosY=obsPath(i,2);
   
   %计算航向角
   head=heading(i);
   
   %根据车尾中心点位置
   [xcar2,ycar2]=getCarAnglePoint(rearPosX,rearPosY,head);
   vehPoint=[xcar2,ycar2];
   
   %依次计算四个点位置距离自车轨迹序列的最小距离的索引
   minDistTemp=zeros(size(vehPoint,1),1);
   minIndexTemp=zeros(size(vehPoint,1),1);
   dist=zeros(size(path_opt,1),1);
   for j=1:size(vehPoint,1)
       dist=sqrt((path_opt(:,1)-vehPoint(j,1)).^2+...
           (path_opt(:,2)-vehPoint(j,2)).^2);
       [minDistTemp(j),minIndexTemp(j)]=min(dist);
   end
   %然后在四个距离中再依次选择最小值，表征障碍车轮廓与本车最小距离
   minDist=min(minDistTemp);
   
   if minDist<1
       %计算minIndexTemp的最小索引和最大索引
       minIdx=min(minIndexTemp);
       maxIdx=max(minIndexTemp);
       
       S_lb(end+1,:)=[t,len_opt(minIdx)];
       S_ub(end+1,:)=[t,len_opt(maxIdx)];

   end
   
   
end
fill(xcar2,ycar2,'y') %2号车

%% 画图
obsZone=[S_lb;S_ub(end:-1:1,:)];
figure
fill(obsZone(:,1),obsZone(:,2),'b');
grid on
axis([0 5 0 45]);
xlabel('时间/s');
ylabel('路程/m');

%% 保存
save stGraph.mat S_lb S_ub obsZone totlen_opt

%% 子函数库
function [xcar2,ycar2]=getCarAnglePoint(x2,y2,f2)
%车辆参数
W=2;       %车宽
L=5;          %车长
[xcar2,ycar2]=RotatePolygon([x2,x2,x2+L,x2+L]',[y2-W/2,y2+W/2,y2+W/2,y2-W/2]',[x2,y2],f2);
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



