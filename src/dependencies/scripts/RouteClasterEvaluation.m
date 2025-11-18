clc
clear
close
load Senario.mat
%% 当前状态
%起点信息
idxA=85;
pos=rightWaypoints(idxA,1:2);

%寻优空间
varNum=[5,5];%分别表示O和C点向前寻优的个数

%初始化存储空间
Path=cell(varNum(1),varNum(2));
Len=cell(varNum(1),varNum(2));
TotLen=zeros(varNum(1),varNum(2));
MeanCur=zeros(varNum(1),varNum(2));
CVpoint=cell(varNum(1),varNum(2));
x=zeros(varNum(1)*varNum(2),1);
y=zeros(varNum(2)*varNum(1),1);

%% 构造换道路径簇
for i=1:varNum(1)
    idxO=idxA+10+i;
   for j=1:varNum(2)
       idxC=idxA+3+j;
       idxF=2*idxO-idxA;
       idxD=idxF-(idxC-idxA);
       
       %控制点
       P1=rightWaypoints(idxA,1:2);
       P3=rightWaypoints(idxC,1:2);
       P4=leftWaypoints(idxD,1:2);
       P6=leftWaypoints(idxF,1:2);
       P2=mean([P1;P3]);
       P5=mean([P4;P6]);
       cv=[P1;P2;P3;P4;P5;P6];
       
       %调用函数生成准均匀B样条曲线
       [Path{i,j},~]=Bspline(cv,[0 3],0.02,2);
       
       %计算用于评价的各项并存储
       Len{i,j}=xy2distance(Path{i,j}(:,1),Path{i,j}(:,2));
       TotLen(i,j)=Len{i,j}(end);
       MeanCur(i,j)=mean(curvature(Path{i,j}(:,1),Path{i,j}(:,2)));
       CVpoint{i,j}=cv;
       
       %构造x,y列向量，用于画评价三维图
       x((i-1)*varNum(1)+j)=idxO;
       y((i-1)*varNum(1)+j)=idxC;
       
   end
end

%% 利用多目标转单目标方法求解B样条曲线最优控制点
%单独取出路径长度、平均曲率2个分代价值
f1=TotLen;
f2=MeanCur;

%根据权重系数，构造综合目标函数
f1_norm=mapminmax(f1,0,1);
f2_norm=mapminmax(f2,0,1);
alpha=[0.3,0.7];
f_all=alpha(1)*f1_norm+alpha(2)*f2_norm;

%求解综合戴杰函数的最小值的索引
f_min=min(f_all,[],'all');
idx=find(f_all==f_min);
path_opt=Path{idx};
len_opt=Len{idx};
totlen_opt=TotLen(idx);
%% 画图
plot(scenario)
hold on
restart(scenario)
for i=1:round(idxA/(0.75))
    advance(scenario);
end
for i=1:varNum(1)
   for j=1:varNum(2)
       plot(Path{i,j}(:,1),Path{i,j}(:,2),'b');
   end
end
plot(path_opt(:,1),path_opt(:,2),'r','linewidth',1.5);
axis([-30 20 -40 40])
title('综合指标筛选最优换道路径')
hold off

%画代价函数变化曲面
z=f_all(:);
[X,Y]=meshgrid(linspace(min(x),max(x),100)',linspace(min(y),max(y),100));
Z=griddata(x,y,z,X,Y,'cubic');
figure
surf(X,Y,Z) %画曲面图
shading flat %各小曲面之间不要网格
xlabel('O点序号idx_O');
ylabel('C点序号idx_C');
zlabel('综合指标评价函数值');

%% 保存
save optPath.mat path_opt len_opt totlen_opt




