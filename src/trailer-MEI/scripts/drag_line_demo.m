gamma = 1;
% th_end = 0.01;
% th_step = 0.1;
% th = gamma:-th_step:th_end;

t = 0:0.2:5;
v = 11.2;
L = 11;

th = pi-2*atan(tan((pi-gamma)/2)*exp(v/L*t));
trailer.x = -(L*(log(tan(th/2))+cos(th)) - L*(log(tan(gamma/2))+cos(gamma)));
trailer.y = -(L*sin(th) - L*sin(gamma));
tractor.x = t*v + L*cos(gamma);
tractor.y = 0*t + L*sin(gamma);

figure(1)
clf
hold on
plot(trailer.x,trailer.y,'Color','b')
scatter(trailer.x,trailer.y,'filled','o','MarkerFaceColor','b')
plot(tractor.x,tractor.y,'Color','r')
scatter(tractor.x,tractor.y,'filled','o','MarkerFaceColor','r')
for i = 1:length(t)
    plot([tractor.x(i) trailer.x(i)],[tractor.y(i) trailer.y(i)],'Color','g')
end


axis equal
grid on;