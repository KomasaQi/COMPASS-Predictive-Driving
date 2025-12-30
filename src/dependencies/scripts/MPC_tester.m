Ts = 0.05;
fr = pi/6;
vr = 15 ;
deltar = 0.3;
l = 2.7;

a = [1,  0, -Ts*vr*sin(fr);
     0,  1,  Ts*vr*cos(fr);
     0,  0,                 1];

b = [cos(fr), 0;
     sin(fr), 0;
     tan(deltar)/l, vr/(l*cos(deltar)^2)]*Ts;
c = eye(3);
x=[1,2,0.4]';
u = [0,0]';

Np = 20;
Nc = 3;
Ny = 3;
Q = diag([1,1,1.2]);
R = diag([0.1,0.5]);
rho = 100;
Yr = zeros(Np*Ny,1);
rate_delta=90/180*pi;
dt = Ts;
uconstrain=[-10,        10,     -0.2*9.806*dt,0.2*9.806*dt;
           -30*pi/180,30*pi/180, -rate_delta,rate_delta];
yconstrain=[-1, 1;-0.05, 0.05;-0.1, 0.1];


du=MPC_Controllor_qpOASES_Ycons(a,b,c,x,u,Q,R,Np,Nc,Yr,uconstrain,yconstrain,rho)