clc
clear
close all
%% 场景设定
d=3.5;        %道路标准宽度
W=1.75;       %车宽

P0 = [0,-d/2,17,0]; %车辆起点信息，x,y,vx,vy
Pg = [110,d/2,17,0]; %目标位置
Pobs=[...
    15   1.75   0   0;
    30   -1.5   0   0;
    60   -1.25  0   0;
    90   1.75   0   0;
    ];                %障碍物位置
P=[Pobs;Pg];          %将目标位置与障碍物位置放在一起

eta_att = 1;          %计算引力的增益系数
eta_rep_obs=16;        %计算斥力的增益系数
eta_rep_edge=2;      %计算车道边界斥力的增益系数

d0=25;               %障碍物影响距离
n=size(P,1);         %障碍物与目标总计个数
len_step=0.1;        %步长/m
iter_max=1700;        %最大循环迭代次数
path=zeros(iter_max,size(P,2));
dt=zeros(iter_max,1);
dist=zeros(n,1);
delta=zeros(n,2);
normdelta=zeros(n,1);
unitVec=zeros(n,2);
normUnitVec=zeros(n-1,2);
F_rep_obs=zeros(n-1,2);
F_rep_ege=zeros(1,2);
%% ************初始化结束，开始主体循环**************
Pi = P0;  %将车的起始坐标赋给Xi
i=0;
%当车辆与目标点距离小于10*步长时认为已经到达目标点了 
while sqrt((Pi(1)-P(n,1))^2+(Pi(2)-P(n,2))^2)>10*len_step && i<iter_max
    i=i+1;
    path(i,:)=Pi;  %保存车走过的每个点的坐标
    vtemp=norm(Pi(3:4));
    if i~=1 %从第二次循环开始为时间变化赋值
        diffVec=path(i,1:2)-path(i-1,1:2);
        dt(i-1)=sqrt(sum(diffVec.^2))/vtemp;
    end
    %计算车辆当前位置与障碍物的单位方向向量、速度向量
    for j=1:n-1
        delta(j,:)=Pi(1:2)-P(j,1:2);  %用车辆点-障碍点表达斥力
        normdelta(j)=norm(delta(j,:));
        dist(j)=norm(delta(j,:)); %车辆当前位置与障碍物的距离
        unitVec(j,:)=delta(j,:)/dist(j); %斥力的单位方向向量
    end
    %计算车辆当前位置与目标的单位方向向量、速度向量
    delta(n,:)=P(n,1:2)-Pi(1:2); %用目标点-车辆点表达引力
    dist(n)=norm(delta(n,:));
    unitVec(n,:)=delta(n,:)/dist(n);
    %计算障碍物给车辆的法向单位向量
    for j=1:n-1
        normUnitVec(j,:)=FindNearNormVec(unitVec(j,:),unitVec(n,:));
    end
    %% 计算斥力
    %在原斥力场函数增加目标调节因子（即车辆至目标距离），以使车辆到达目标点后斥力也为0
    for j=1:n-1
        if dist(j)>=d0
            F_rep_obs(j,:)=[0,0];
        else
            %障碍物的斥力1，方向由障碍物指向车辆
            F_rep1=(eta_rep_obs*(1/dist(j)-1/d0)*dist(n)/dist(j).^2).*unitVec(j,:);
            %障碍物的斥力2，方向由车辆指向目标点
            F_rep2=(0.3*eta_rep_obs*(1/dist(j)-1/d0).^2).*unitVec(n,:);
            %障碍物的斥力3，方向由车辆指向车与障碍物连线的法向量中与目标点呈锐角的那个法向量
            F_rep3=0.5*F_rep1.*normUnitVec(j,:);
            %改进后的障碍物合斥力计算
            F_rep_obs(j,:)=F_rep1+F_rep2+F_rep3;
        end
    end
    %计算距离所有障碍物中最近的一个的距离
    distNear=min(normdelta);
    scaleFac=min(distNear/30,1).^2;
    %增加边界斥力势场，根据车辆当前位置，选择对应的斥力函数
    if Pi(2)>-d && Pi(2)<=-d*0.4 %下道路边界区域力场
        F_rep_edge=[0,eta_rep_edge*vtemp*(exp(-d/2-Pi(2)))];
    elseif Pi(2)>-d*0.4 && Pi(2)<=-W/2 %下道路分界线区域力场
        F_rep_edge=[0,(-1/25*eta_rep_edge*Pi(2).^2)*scaleFac];
    elseif Pi(2)>W/2 && Pi(2)<=d*0.4 %上道路分界线区域力场
        F_rep_edge=[0,(1/25*eta_rep_edge*Pi(2).^2)*scaleFac];
    elseif Pi(2)>d*0.4 && Pi(2)<=d %上道路边界区域力场
        F_rep_edge=[0,-eta_rep_edge*vtemp*(exp(Pi(2)-d/2))];
    else
        F_rep_edge=[0,0];
    end
    %计算合力和方向
    F_rep=sum(F_rep_obs)+F_rep_edge;
    F_att=(eta_att*dist(n)).*unitVec(n,:);
    F_sum=F_rep+F_att;
    UnitVec_Fsum=F_sum/norm(F_sum);
    
    %计算车的下一步位置
    Pi(1:2)=Pi(1:2)+len_step*UnitVec_Fsum;
    disp(['已经计算' num2str(i) '步，完成' num2str(100*i/iter_max) '%'])
end
path(i,:)=P(n,:);%把路径向量最后一个点赋值为目标点
path(i+1:end,:)=[]; %删除多余的路径空间
dt(i:end,:)=[]; %删除多余的时间空间
t=[0;cumsum(dt)];





%% 场景定义
%环岛场景路段与车辆相关参数的定义
d=3.5;        %道路标准宽度
len_lane=path(end,1)+10;  %直线段长度
W=1.75;       %车宽
L=3;          %车长
% 车辆换道初始状态与终点期望状态
x2=path(1,1);
y2=path(1,2);

%% 画场景示意图
figure(1)
%画灰色路面图
GreyZone=[-5,-d-0.5;-5,d+0.5;len_lane,d+0.5;len_lane,-d-0.5];
fill(GreyZone(:,1),GreyZone(:,2),[0.5,0.5,0.5]);
hold on
%画小车
fill([x2,x2,x2+L,x2+L],[y2-W/2,y2+W/2,y2+W/2,y2-W/2],'y') %1号车
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
% 画障碍物和目标终点
scatter(Pg(1),Pg(2),'r');
scatter(P(1:n-1,1),P(1:n-1,2),'b')
fig = get(groot,'CurrentFigure');
fig.Position=[200 400 1500 400];
% figure('Units','centimeter','Position',[5 15 25 10]);
hold off


function nearNormVec=FindNearNormVec(vec,targetVec)
NormVec{1}=rotate(vec,pi/2);
NormVec{2}=rotate(vec,-pi/2);
for i=1:2
    if sum(NormVec{i}.*targetVec)>0
        nearNormVec=NormVec{i};
        break;
    end
end

end

function vec1 = rotate(vec0,th)
vec1(1)=cos(th)*vec0(1)-sin(th)*vec0(2);
vec1(2)=sin(th)*vec0(1)+cos(th)*vec0(2);
end
