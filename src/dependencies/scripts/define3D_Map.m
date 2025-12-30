clc
clear
close all

%% 初始化地形信息
mapRange=[100,100,30];  %地图长宽高范围
N=10;                    %山峰个数
peaksInfo = struct;      %初始化山峰特征信息结构体
peaksInfo.center=[];     %山峰中心
peaksInfo.height=[];      %山峰高度
peaksInfo.range=[];      %山峰区域
peaksInfo=repmat(peaksInfo,N,1);

%% 随机生成N个山峰的特征参数
for i=1:N
   peaksInfo(i).center=[mapRange(1)*(rand*0.8+0.2),mapRange(2)*(rand*0.8+0.2)];
   peaksInfo(i).height=mapRange(3)*(rand*0.7+0.3);
   peaksInfo(i).range=mapRange*0.5*(rand*0.7*0.8);
end
    
%% 计算山峰曲面值
x=1:1:mapRange(1);
y=1:1:mapRange(2);
peakData = zeros(length(x),length(y));
for i=1:length(x)
    for j=1:length(y)
        sum=0;
        for k=1:N
            hi = peaksInfo(k).height;
            xi = peaksInfo(k).center(1);
            yi = peaksInfo(k).center(2);
            xsi= peaksInfo(k).range(1);
            ysi= peaksInfo(k).range(2);
            sum=sum+hi*exp(-((x(i)-xi)/xsi).^2-((y(j)-yi)/ysi).^2);
        end
        peakData(i,j)=sum;
    end
end

%% 构造曲面网格用于后期MAP图插值判断三维路径是否与山峰交涉

[X,Y]=meshgrid(x,y);
surf(X,Y,peakData);
axis equal
shading flat
%% 保存生成的地图
map.x=X;
map.y=Y;
map.z=peakData;

save Map3D001.mat map





















