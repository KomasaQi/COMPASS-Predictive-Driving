dT = 0.5;
t = 0:dT:20;
decT = [0 1 2 3 4 5 6 7 8 10 12 14 16 18 20];
sampleNum = 10;
a = linspace(-2,1.5,sampleNum);
s0 = 0;
v0 = 80/3.6;
vmin = 60/3.6;
vmax = 120/3.6;
trajs = ones(length(t),sampleNum)*s0;
v = v0*ones(1,sampleNum);
for i = 2:length(t)
    v = v + a*dT;
    v(v>vmax) = vmax;
    v(v<vmin) = vmin;
    acc = a;
    acc(v>=vmax) = 0;
    acc(v<=vmin) = 0;
    trajs(i,:) = trajs(i-1,:) + v*dT + 1/2*acc*dT^2;
end
hold on
plot(t,trajs,'Color','b')
xlabel('time [s]')
ylabel('distance [m]')
legend('0-120km/h','60-120km/h',Location='northwest')