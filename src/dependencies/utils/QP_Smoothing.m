function routeqp  = QP_Smoothing(egoSpd,egoAcc,egoJerk,route,obs1,obs2,constrain,Slim)
%% 参数初始化
%性能函数指标权重
w1=5.0; %加速度权重
w2=5.0;   %加加速度权重
w3=100;%与动态规划得到的最优ST曲线的误差指标权重

%初始状态
initstate=[0,norm(egoSpd),egoAcc,egoJerk];
%DP和QP的离散时间和阶段数量
dt_DP=route(2,1)-route(1,1);
dt_QP=0.1;
n_DP=size(route,1)-1;
n_QP=dt_DP/dt_QP;

%运动约束
% constrain=[2,25;9.81*-1.2,9.81*0.4;-inf,inf];
vlim=constrain(1,:);
alim=constrain(2,:);
% jlim=[max([constrain(3,1);-40]),min([constrain(3,2),40])];

%% 目标函数
H=zeros(6*n_DP); %初始化H矩阵
f=zeros(6*n_DP,1);%初始化f矩阵
t=dt_DP;         %每一段5次曲线的终点时刻
for i=1:n_DP
   %加速度指标
   H1=2*[
       0    0     0       0       0         0;
       0    0     0       0       0         0;
       0    0    4*t    6*t^2   8*t^3     10*t^4;  
       0    0    6*t^2  12*t^3  18*t^4    24*t^5;
       0    0    8*t^3  18*t^4  144/5*t^5 40*t^6;
       0    0    10*t^4 24*t^5  40*t^6   400/7*t^7]; 
   %加加速度指标
   H2=2*[
       0    0    0     0       0       0;
       0    0    0     0       0       0;
       0    0    0     0       0       0;
       0    0    0    36*t    72*t^2   120*t^3; 
       0    0    0    72*t^2  192*t^3  360*t^4;
       0    0    0    120*t^3 360*t^4  720*t^5]; 
   %与动态规划得到的最优ST曲线的误差指标
   H3=2*[
       1	  t	     t^2    t^3    t^4   t^5;
       t	  t^2    t^3    t^4    t^5   t^6;
       t^2    t^3    t^4    t^5    t^6   t^7;
       t^3    t^4    t^5    t^6    t^7   t^8;
       t^4    t^5    t^6    t^7    t^8   t^9;
       t^5    t^6    t^7    t^8    t^9   t^10];
    %将上述计算的个性能指标按照权重相加，构造H矩阵
    idx1=(i-1)*6+1;
    idx2=i*6;
    Htemp=w1*H1+w2*H2+w3*H3;
    H(idx1:idx2,idx1:idx2)=Htemp;
    
    %由于“与期望的DP生成的S产生的误差”会产生f项，在此添加
    refS=route(i+1,2);
    tempF=-2*refS*[1 t  t^2  t^3  t^4  t^5]'*w3;
    f(idx1:idx2)=tempF;
   
end
%可视化H矩阵
visualize=0;
if visualize==1
[X,Y]=meshgrid(1:6*n_DP,1:6*n_DP);
surf(X,Y,H)
shading flat %各小曲面之间不要网格
end

%% 等式约束
%每一段的相邻连接点约束，位置、速度、加速度、加加速度约束
Aeq1=zeros((n_DP-1)*4,n_DP*6);
Beq1=zeros(1,(n_DP-1)*4);
for i=1:n_DP-1
    t=dt_DP;
    %位置、速度、加速度、加加速度约束
    aeq1=[1	t t^2   t^3   t^4    t^5 -1  0  0  0  0  0];
    aeq2=[0 1 2*t 3*t^2 4*t^3  5*t^4  0 -1  0  0  0  0];
    aeq3=[0	0 2   6*t  12*t^2 20*t^3  0  0 -2  0  0  0];
    aeq4=[0 0 0   6    24*t   60*t^2  0  0  0 -6  0  0];
    %b向量
    beq=[0 0 0 0]';
    %将此段的约束添加到大矩阵中
    startRow=(i-1)*4+1;
    endRow=i*4;
    startCol=(i-1)*6+1;
    endCol=(i+1)*6;
    Aeq1(startRow:endRow,startCol:endCol)=[aeq1;aeq2;aeq3;aeq4];
    Beq1(startRow:endRow)=beq;
end
 %ST曲线起点的位置、速度、加速度约束
 Aeq2=zeros(3,6*n_DP);
 Beq2=zeros(1,3);
 t=0;
 aeq1=[1 t t^2   t^3   t^4    t^5];
 aeq2=[0 1 2*t 3*t^2 4*t^3  5*t^4];
 aeq3=[0 0 2   6*t  12*t^2 20*t^3];
 beq=[route(1,2),initstate(2:3)];
 Aeq2(1:3,1:6)=[aeq1;aeq2;aeq3];
 Beq2(1:3)=beq;
 
 %组建等式约束矩阵
 Aeq=[Aeq1;Aeq2];
 Beq=[Beq1,Beq2];
 
 %% 线性不等式约束
  %ST图的障碍物上下边界约束
  A3=zeros((n_DP-1)*2*n_QP+n_QP*2,n_DP*6);
  B3=zeros((n_DP-1)*2*n_QP+n_QP*2,1);
  figure,hold on
 for i=1:n_DP
     for j=1:n_QP
         t=j*dt_QP;
         time=(i-1)*dt_DP+t;
         %找到此时刻DP规划路径点的插值
         Sdp=interp1(route(:,1),route(:,2),time);
         %找到此时刻距离DP路径点最近的上下障碍物边界，无则为无穷
         [lb,ub]=ObstacleBdy(obs1,obs2,[time,Sdp],Slim);
         
         scatter(time,lb)
         scatter(time,ub)
         pause(0.05)
         
         %构造Ax<=b
         a1=-[1 t t^2   t^3   t^4    t^5];
         a2=[1 t t^2   t^3   t^4    t^5];
         b=[-lb;ub];
         %行列索引
         startRow=(i-1)*2*n_QP+(j-1)*2+1;
         endRow=(i-1)*2*n_QP+j*2;
         startCol=(i-1)*6+1;
         endCol=i*6;
         %添加到A,B大矩阵中
         A3(startRow:endRow,startCol:endCol)=[a1;a2];
         B3(startRow:endRow,1)=b;
     end
 end
 %速度约束
 A1=zeros((n_DP-1)*2*n_QP+n_QP*2,n_DP*6);
 B1=zeros((n_DP-1)*2*n_QP+n_QP*2,1);
 for i=1:n_DP
     for j=1:n_QP
         t=j*dt_QP;
         %上下边界
         lb=vlim(1);
         ub=vlim(2);
         %构造Ax<=b
         a1=-[0 1 2*t 3*t^2 4*t^3  5*t^4];
         a2=[0 1 2*t 3*t^2 4*t^3  5*t^4];
         b=[-lb;ub];
         %行列索引
         startRow=(i-1)*2*n_QP+(j-1)*2+1;
         endRow=(i-1)*2*n_QP+j*2;
         startCol=(i-1)*6+1;
         endCol=i*6;
         %添加到A,B大矩阵中
         A1(startRow:endRow,startCol:endCol)=[a1;a2];
         B1(startRow:endRow,1)=b;
     end
 end
 %加速度约束
  A2=zeros((n_DP-1)*2*n_QP+n_QP*2,n_DP*6);
  B2=zeros((n_DP-1)*2*n_QP+n_QP*2,1);
 for i=1:n_DP
     for j=1:n_QP
         t=j*dt_QP;
         %上下边界
         lb=alim(1);
         ub=alim(2);
         %构造Ax<=b
         a1=-[0 0 2   6*t  12*t^2 20*t^3];
         a2=[0 0 2   6*t  12*t^2 20*t^3];
         b=[-lb;ub];
         %行列索引
         startRow=(i-1)*2*n_QP+(j-1)*2+1;
         endRow=(i-1)*2*n_QP+j*2;
         startCol=(i-1)*6+1;
         endCol=i*6;
         %添加到A,B大矩阵中
         A2(startRow:endRow,startCol:endCol)=[a1;a2];
         B2(startRow:endRow,1)=b;
     end
 end
 
 %组建不等式约束矩阵
 A=[A1;A2;A3];
 B=[B1;B2;B3];

 %调用QP算法
 coder.extrinsic('quadprog');
 coder.extrinsic('optimoptions');
 options=optimoptions('quadprog','MaxIterations',100,'TolFun',1e-16);
 x=quadprog(H,f,A,B,Aeq,Beq,[],[],[],options);
 %% 将得到的解x重新调整为n_DP段

 c=zeros(6,n_DP);
 for i=1:n_DP
 c(:,i)=x((i-1)*6+1:i*6);
 end
 t=route(1,1):dt_QP:route(end,1);
 routeqp=zeros(81,3);
 routeqp(1:81,1)=t';
 for i=1:n_DP
    if i==1
        routeqp(1,2)=route(1,2);
        routeqp(1,3)=initstate(2);
    end
    for j=1:n_QP
        idx=(i-1)*n_QP +j+1;
        t=j*dt_QP;
        %位置
        routeqp(idx,2)=c(1,i)+c(2,i)*t+c(3,i)*t^2+c(4,i)*t^3+c(5,i)*t^4+c(6,i)*t^5;
        %速度
        routeqp(idx,3)=c(2,i)+2*c(3,i)*t+3*c(4,i)*t^2+4*c(5,i)*t^3+5*c(6,i)*t^4;
    end
     
 end


end


function [lb,ub]=ObstacleBdy(obs1,obs2,point,Slim)
%% 基本参数获取
obsNum=2;
%% 对每个障碍物进行判断
ubs=zeros(obsNum,1);
lbs=zeros(obsNum,1);

    %当前时刻为t,即point(1);如果点S>lb && S<ub，则在障碍物中
    %插值获得当前t时刻障碍物的上下界限
    lbs(1)=interp1(obs1(:,1),obs1(:,2),point(1),'linear',Slim(2));
    if lbs(1)<point(2) || isinf(lbs(1))
        lbs(1)=Slim(2);
    end
    ubs(1)=interp1(obs1(:,1),obs1(:,3),point(1),'linear',Slim(1));
    if ubs(1)>point(2)  || isinf(ubs(1))
        ubs(1)=Slim(1)-1;
    end
    
    lbs(2)=interp1(obs2(:,1),obs2(:,2),point(1),'linear',Slim(2));
    if lbs(2)<point(2)  || isinf(lbs(2))
        lbs(2)=Slim(2);
    end
    ubs(2)=interp1(obs2(:,1),obs2(:,3),point(1),'linear',Slim(1));
    if ubs(2)>point(2) || isinf(ubs(2))
        ubs(2)=Slim(1)-1;
    end

ub=min(lbs);
lb=max(ubs);


end
