%% 函数：MPC控制器：MPC_Controllor_qpOASES_Ycons*********************************
%****************************使用说明*****************************************************
% ●输入：
%   a,b,c:  为离散形式的模型A,B,C矩阵
%   Q,R:    最优调节的Q，R矩阵，Q为半正定，R为正定
%   x,u:    状态量x(k)和控制量u(k-1)
%   Np,Nc:  Np和Nc分别为预测时域和控制时域个数
%   uconstrain: 控制量及其变化量的限制，形式如下：
%               [u1min u1max du1min du1max;
%               u2min u2max du2min du2max];
%   yconstrain：为观测量，即系统输出的限制，可以设计为硬约束或者软约束，这里使用软约束。
%               假设观测量数量为3个，即Ny=3，则使用样例如下：
%               [y1min y1max;
%                y2min y2max;
%                y3min;y3max];
%   rho:    为松弛因子权重，大于0的数字，数值大表示限制松弛因子，即对输出量的约束更硬。
% ●输出:
%   du：    控制量的变化量，Nu x 1
%****************************************************************************************
% 调教MPC时可用以下参数初始化：
% a=rand(3);b=rand(3,2);c=eye(3);x=rand(3,1);u=[0;0];Q=eye(3);R=0.1*eye(2);rho=5;
% Np=50;Nc=3;Yr=zeros(Np*size(c,1),1);uconstrain=[-1 1 -0.1 0.1; -2 2 -0.2 0.2];
% yconstrain=[-0.1,0.1;-1,1;-1,1]*0.01;

function du=MPC_Controllor_qpOASES_Ycons(a,b,c,x,u,Q,R,Np,Nc,Yr,uconstrain,yconstrain,rho)
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
At=[kron(At_tmp,eye(Nu)),zeros(Nu*Nc,1);
                   theta,-ones(Ny*Np,1);
                   theta, ones(Ny*Np,1)];
%控制量及其变化量的限制
Umin=[kron(ones(Nc,1),uconstrain(:,1))];
Umax=[kron(ones(Nc,1),uconstrain(:,2))];
dUmin=[kron(ones(Nc,1),uconstrain(:,3));-1e5];
dUmax=[kron(ones(Nc,1),uconstrain(:,4));1e5];
%上一时刻的控制量
Ut=kron(ones(Nc,1),u);
%输出量约束
Ymin=kron(ones(Np,1),yconstrain(:,1));
Ymax=kron(ones(Np,1),yconstrain(:,2));
%限制量矩阵：
% Acons=[At;-At];
% bcons=[Umax-Ut;-Umin+Ut];
%开始求解过程
% options=optimoptions('quadprog','MaxIterations',100,'TolFun',1e-16);
% dU=quadprog(H,g,Acons,bcons,[],[],dUmin,dUmax,[],options); %（Nu*Nc）x 1
options = qpOASES_options('default', 'printLevel', 0); 
% [dU, FVAL, EXITFLAG, iter, lambda] = qpOASES(H, g, At, dUmin, dUmax, Umin-Ut, Umax-Ut, options); %
[dU, ~, ~, ~, ~] = qpOASES(H, g, At, dUmin, dUmax, [Umin-Ut;ones(Ny*Np,1)*-1e10;Ymin-E], [Umax-Ut;Ymax-E;ones(Ny*Np,1)*1e10], options);
du=dU(1:Nu);

end