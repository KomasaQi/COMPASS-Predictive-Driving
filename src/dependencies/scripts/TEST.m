%目标速度定义
v_tgt=17;
%初始速度定义
vx=10;
%仿真时长
Ts=0.01;
t=1:Ts:10;
%初始化仿真结果输出空间
spd=zeros(length(t),1);

%控制器参数
kp=2000;
ki=10;
kd=2;
%误差计算
e=ones(1,3)*(v_tgt-vx);
ax=0;

for i=1:length(t)
spd(i)=vx;
e=[e(2);e(3);v_tgt-vx];
ax=vxPID(e,ax,kp,ki,kd,Ts);
vx=vx+ax*Ts;
end
figure(1)
plot(t,spd)