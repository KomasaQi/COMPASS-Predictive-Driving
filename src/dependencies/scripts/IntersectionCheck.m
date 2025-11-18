clc
clear
close all
%% 多边形及线段定义
poly1=[-1,1;1,1;1,-1;-1,-1;-1,1];
[x2,y2]=RotatePolygon(poly1(:,1),poly1(:,2),[0,0],0.3);
poly2=[x2+0.5,y2-1.3];
line=cell(6,1);
line{1}=[0.5,0;0.5,1.5];  %X型    相交
line{2}=[0,2;0.3,1];      %T型    相交
line{3}=[-0.5,1.2;-0.6,2];%       不相交
line{4}=[-2,1.5;-1.5,1.5];%       不相交
line{5}=[-2,1;-1.5,1];    %       不相交
line{6}=[-0.5,1;1.5,1];   %重合   相交
line{7}=[-1.2,1;1.2,1];   %过重合 相交

%% 计算是否相交
result=zeros(1,length(line)); %用来储存线段和线段的相交结果
for i=1:length(line)
    result(i)=intersect_lineline(line{i},poly1(1:2,:));
end

result2=zeros(1,size(poly2,1)-1); %用来储存线段和多边形的相交结果
for i=1:length(result2)
    result2(i)=intersect_linepoly(poly2(i:i+1,:),poly1);
end
result3=intersect_polypoly(poly1,poly2);%用来储存两个多边形相交结果

%% 绘制图形
figure(1),hold on
polifill1=fill(poly1(:,1),poly1(:,2),'y');
polyfill2=fill(poly2(:,1),poly2(:,2),'c');
polyfill2.FaceAlpha=0.3;
axis equal
plot(poly1(1:2,1),poly1(1:2,2),'k--','linewidth',2);
plot(poly1(2:end,1),poly1(2:end,2),'k','linewidth',1.5);
for i=1:length(line)
   plot(line{i}(:,1),line{i}(:,2),'-*','linewidth',1.5) ; 
end

for i=find(result==1)
    plot(line{i}(:,1),line{i}(:,2),'-o','linewidth',3) ;
end
for i=find(result2==1)
    plot(poly2(i:i+1,1),poly2(i:i+1,2),'k-o','linewidth',3) ;
end
hold off


fprintf(['对于线段和黄色多边形，相交结果：' num2str(result) '\n即共有'...
    num2str(sum(result)) '条线段与其相交，已标粗\n'])

fprintf(['蓝色多边形共有' num2str(sum(result2)) '条边与黄色多边形相交，已标粗\n'])


%% 子函数:旋转多边形
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