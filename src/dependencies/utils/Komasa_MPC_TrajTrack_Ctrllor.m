%% 主函数 根据标志位flag来切换操作具体方程
function [sys,x0,str,ts] = Komasa_MPC_TrajTrack_Ctrllor(t,x,u,flag)
%   限定于车辆运动学模型，控制量为速度和前轮偏角，使用的QP为新版本的QP解法
%   [sys,x0,str,ts] = MY_MPCController3(t,x,u,flag)
switch flag
 case 0
  [sys,x0,str,ts] = mdlInitializeSizes; % Initialization 
 case 2
  sys = mdlUpdates(t,x,u); % Update discrete states
 case 3
  sys = mdlOutputs(t,x,u); % Calculate outputs
 case {1,4,9} % Unused flags
  sys = []; 
 otherwise
  error(['unhandled flag = ',num2str(flag)]); % Error handling
end
% End of dsfunc.
end
%% 模块初始化
%==============================================================
% Initialization
%==============================================================
function [sys,x0,str,ts] = mdlInitializeSizes

% Call simsizes for a sizes structure, fill it in, and convert it 
% to a sizes array.

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 3; % this parameter doesn't matter
sizes.NumOutputs     = 2; %[speed, steering]
sizes.NumInputs      = 5;
sizes.DirFeedthrough = 1; % Matrix D is non-empty.
sizes.NumSampleTimes = 1;
sys = simsizes(sizes); 
x0 =[0;0;0];   
global U; % store current ctrl vector:[vel_m, delta_m]
U=[0;0];
global path cur len refDelta refHead L
[path,cur,len]=getPath('S');
% 获得参考前轮转角
L=2.866;    %轴距
refDelta=atan(cur.*L); 
%获得参考航向角
diff_x=diff(path(:,1));
diff_y=diff(path(:,2));
refHead=zeros(size(path,1),1);
refHead(1:end-1) = atan2(diff_y,diff_x);
refHead(end)=refHead(end-1);
% Initialize the discrete states.
str = [];             % Set str to an empty matrix.
ts  = [0.05 0];       % sample time: [period, offset]
%End of mdlInitializeSizes
end		 
%% 更新离散状态量
%==============================================================
% Update the discrete states
%==============================================================
function sys = mdlUpdates(t,x,u)
sys = x;
%End of mdlUpdate.
end
%% 更新输出量
%==============================================================
% Calculate outputs
%==============================================================
function sys = mdlOutputs(t,x,u)
global path refDelta refHead L
   %% 相关参数定义
%MPC控制器参数
Q=diag([20,20,10]);
R=diag([20,100]);
Np=10;
Nc=6;
rho=10;   %松弛因子系数
Ts=0.05;   %控制步长，单位：s
v_tgt=62/3.6;
%% 主程序
    %从CarSim获得观测量
    pos=zeros(1,2);
    pos(1)=u(1);
    pos(2)=u(2);
    head=u(3)/180*pi;
    spd=u(4)/3.6;
    delta=u(5)/180*pi;
    % 获得参考量
    idx=findTargetIdx(pos,path);
    %MPC控制器
    [dv,ddelta]=MPC_Ctrllor(pos,head,path(idx,1:2),refHead(idx),Ts,v_tgt,refDelta(idx),Q,R,L,spd,delta,Np,Nc,rho);
    %更新车辆控制状态
    deltacmd=ddelta+delta;
    deltacmd=sign(deltacmd)*min([abs(deltacmd),30/180*pi]);
    spdcmd=spd+dv;

    sys= [spdcmd; deltacmd]; % vel, steering, x, y
% End of mdlOutputs.
end
%% 子函数:MPC控制器
function [dv,ddelta]=MPC_Ctrllor(pos,head,refPos,refHead,dt,Vref,refDelta,Q,R,L,v,delta,Np,Nc,rho)
%求位置、航向角偏差量
ex=pos(1)-refPos(1);
ey=pos(2)-refPos(2);
eh=head-refHead;

%由状态方程系数矩阵，计算K
a=[1,   0,   -Vref*dt*sin(refHead);
   0,   1,   Vref*dt*cos(refHead);
   0,   0,         1             ];
b=[cos(refHead),          0;
   sin(refHead),          0;
   tan(refDelta)/L,  Vref/(L*cos(refDelta)^2)]*dt;
c=eye(3);
%MPC控制器相关参数
x=[ex;ey;eh];
u=[v-Vref;delta-refDelta];
rate_delta=90/180*pi;%限定方向盘转动速度
uconstrain=[-5,        5,     -0.2*9.806*dt,0.2*9.806*dt;
          -30*pi/180,30*pi/180, -rate_delta,rate_delta];
%参考偏差量
Yr=zeros(Np*size(c,1),1);
%获得前轮速度变化量、前轮转角变化量两个控制量
du=MPC_Controllor_qpOASES(a,b,c,x,u,Q,R,Np,Nc,Yr,uconstrain,rho);

%获取相对参考量的控制变化量输出
dv_ref=du(1);
ddelta_ref=du(2);  

%对速度变化量进行变换与限幅
v_tmp=Vref+dv_ref;
ddv=v_tmp-v;
dv=sign(ddv)*min([abs(ddv),dt*0.2*9.806]);
%对转角变化量进行变换
delta_tmp=refDelta+ddelta_ref;
ddd=delta_tmp-delta;
ddelta=sign(ddd)*min([abs(ddd),dt*180/180*pi]);
end

function [path,cur,len]=getPath(pathname)
    % pathname='S';%轨迹可选为单移线'SLC'或S型'S'
    %% 获得参考轨迹
    if strcmp(pathname,'SLC')
        [path,cur,len]=getSingleLaneChangePath(50,'poly');
    elseif strcmp(pathname,'S')
        load S_path.mat path;
        cur=curvature(path(:,1),path(:,2));
        len=xy2distance(path(:,1),path(:,2));
    else
        disp('请输入合法的换道轨迹名称呀');
    end
end
%% 子函数：获取参考轨迹最近的点
function idx=findTargetIdx(pos,path)
dist=zeros(size(path,1),1);
for i=1:size(dist,1)
   dist(i,1)=norm(path(i,1:2)-pos);
end
[~,idx]=min(dist); %找到距离当前位置最近的一个参考轨迹点的序号和距离

end
%% 子函数：MPC控制器 使用qpOASES求解器
function du=MPC_Controllor_qpOASES(a,b,c,x,u,Q,R,Np,Nc,Yr,uconstrain,rho)
%% 模型处理 
%统计模型状态、控制量和观测量维度
Nx=size(a,1); %状态量个数
Nu=size(b,2); %控制量个数
Ny=size(c,1); %观测量个数
%构建控制矩阵
A=[a,b;zeros(Nu,Nx),eye(Nu)]; %(Nx+Nu) x (Nx+Nu)
B=[b;eye(Nu)];                %(Nx+Nu) x Nu
C=[c zeros(Ny,Nu)];           %   Ny   x (Nx+Nu)
%新的控制量为ksai(k)=[x(k),u(k-1)]'
ksai=[x;u];
%新的状态空间表达式为：ksai(k+1)=A*ksai(k)+B*du(k)  
%输出方程为： ita(k)=C*ksai(k)   %Ny x 1

%% 预测输出
% 获取相关预测矩阵
psai=zeros(Ny*Np,Nx+Nu); %矩阵psai
for i=1:Np
    psai(((i-1)*Ny+1):i*Ny,:)=C*A^i;
end
theta=zeros(Np*Ny,Nc*Nu); %矩阵theta
for i=1:Np
   for j=1:i
       if j<=Nc
       theta(((i-1)*Ny+1):i*Ny,((j-1)*Nu+1):j*Nu)=C*(A^(i-j))*B;
       else
       end
   end
end
%输出方程可以写为 Y=psai*ksai(k)+theta*dU  % Ny*Np x 1

%% 控制
% 变量设置
E=psai*ksai;
Qq=kron(eye(Np),Q);
Rr=kron(eye(Nc),R);
% 目标函数设计
% H=theta'*Qq*theta+Rr;
H=[theta'*Qq*theta+Rr,zeros(Nu*Nc,1);zeros(1,Nu*Nc),rho];
H=(H+H')/2;%保证矩阵对称
g=[(E'*Qq*theta - Yr'*Qq*theta)';0];
% 约束条件相关矩阵
At_tmp=zeros(Nc); %下三角方阵
for i=1:Nc
    At_tmp(i,1:i)=1;
end
At=[kron(At_tmp,eye(Nu)),zeros(Nu*Nc,1)];
%控制量及其变化量的限制
Umin=kron(ones(Nc,1),uconstrain(:,1));
Umax=kron(ones(Nc,1),uconstrain(:,2));
dUmin=[kron(ones(Nc,1),uconstrain(:,3));-1e10];
dUmax=[kron(ones(Nc,1),uconstrain(:,4));1e10];
%上一时刻的控制量
Ut=kron(ones(Nc,1),u);
%限制量矩阵：
% Acons=[At;-At];
% bcons=[Umax-Ut;-Umin+Ut];
%开始求解过程
% options=optimoptions('quadprog','MaxIterations',100,'TolFun',1e-16);
% dU=quadprog(H,g,Acons,bcons,[],[],dUmin,dUmax,[],options); %（Nu*Nc）x 1
options = qpOASES_options('default', 'printLevel', 0); 
% [dU, FVAL, EXITFLAG, iter, lambda] = qpOASES(H, g, At, dUmin, dUmax, Umin-Ut, Umax-Ut, options); %
[dU, ~, ~, ~, ~] = qpOASES(H, g, At, dUmin, dUmax, Umin-Ut, Umax-Ut, options);
du=dU(1:Nu);

end
% 函数：MPC控制器%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 输入：
% 为离散形式的模型A,B,C矩阵
% 最优调节的Q，R矩阵，Q为半正定，R为正定
% 状态量x(k)和控制量u(k-1)
% Np和Nc分别为预测时域和控制时域个数
% uconstrain为控制量及其变化量的限制，形式如下：
%[u1min u1max du1min du1max;
% u2min u2max du2min du2max];
% rho为松弛系数
% 输出:
% du为控制量的变化量

% 调教MPC时可用以下参数初始化：
% a=rand(3);
% b=rand(3,2);
% c=eye(3);
% x=rand(3,1);
% u=[0;0];
% Q=eye(3);
% R=0.1*eye(2);
% rho=5;
% Np=50;
% Nc=3;
% Yr=zeros(Np*size(c,1),1);
% uconstrain=[-1 1 -0.1 0.1; -2 2 -0.2 0.2];