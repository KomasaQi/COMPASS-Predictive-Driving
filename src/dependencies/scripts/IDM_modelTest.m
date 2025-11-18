% 设置随机种子为固定值（例如123）
rng(124);

car1.pos = 90;
car1.v = 0;
car1.idm = IDM();

car2.pos = 0;
car2.v = 20;
car2.idm = IDM();

CarNum = 2;
tspan = [0 200];
Ts = 0.1;

t = (tspan(1):Ts:tspan(2))';
position = zeros(length(t),CarNum);
velocity = zeros(length(t),CarNum);

for i = 1:length(t)
    position(i,:) = [car1.pos, car2.pos];
    velocity(i,:) = [car1.v, car2.v];
    car1.a = car1.idm.acc(car1.v,100,100);
    car2.a = car2.idm.acc(car2.v,car1.v,car1.pos-car1.idm.L-car2.pos);
    car1.v = car1.v + Ts*car1.a;
    car2.v = car2.v + Ts*car2.a;
    
    car1.idm.a_max = car1.idm.a_max + 0.03*randn()*Ts;
    car1.idm.b     = car1.idm.b     + 0.05*randn()*Ts; 
    car1.idm.v_des = car1.idm.v_des + 0.2*randn()*Ts;
    car1.idm.s_min = car1.idm.s_min + 0.01*randn()*Ts;
    car1.idm.delta = car1.idm.delta + 0.04*randn()*Ts;
    car1.idm.T     = car1.idm.T     + 0.03*randn()*Ts;

    car2.idm.a_max = car2.idm.a_max + 0.03*randn()*Ts;
    car2.idm.b     = car2.idm.b     + 0.05*randn()*Ts; 
    car2.idm.v_des = car2.idm.v_des + 0.3*randn()*Ts;
    car2.idm.s_min = car2.idm.s_min + 0.01*randn()*Ts;
    car2.idm.delta = car2.idm.delta + 0.04*randn()*Ts;
    car2.idm.T     = car2.idm.T     + 0.03*randn()*Ts;

    car1.pos = car1.pos + car1.v*Ts + Ts*Ts*car1.a;
    car2.pos = car2.pos + car2.v*Ts + Ts*Ts*car2.a;
end

figure(1)
plot(t,position(:,1),t,position(:,2));
figure(2)
plot(t,velocity(:,1),t,velocity(:,2));



