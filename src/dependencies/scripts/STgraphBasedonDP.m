clc
clear
close all
load stGraph.mat
Obs{1}=[S_lb,S_ub(:,2)];
Obs{2}=[S_lb(:,1)+1.5,(S_lb(:,2)+35),(S_ub(:,2)+38)];
tseq=[0:0.5:5];
dS=0.2;
Slim=[0,100]; 
initstate=[0,18,0,0];
constrain=[7,25;-9.81*1.0,9.81*0.8;-50,50];
[route,Spast,ListNum]=DPforSTgraph1(initstate,tseq,dS,Slim,constrain,Obs,@costFcn);



%% 画图

figure(1)
hold on
for i=1:length(Obs)
    obsZone=[Obs{i}(:,[1 2]);Obs{i}(end:-1:1,1),Obs{i}(end:-1:1,3)];
    fill(obsZone(:,1),obsZone(:,2),'b');
end
% 
% for i=1:length(Spast)
%    plot(route(:,1),Spast{i}.path,'g');
% end
for i=1:ListNum
   plot(route(:,1),Spast(i,1:length(tseq)),'g');
end
plot(route(:,1),route(:,2),'r','linewidth',1.5);
scatter(route(:,1),route(:,2),'r','filled');
grid on
axis([0 5 0 80]);
xlabel('时间/s');
ylabel('路程/m');
hold off

%% 保存
save ST_opt.mat route Obs initstate constrain Slim

%% 自定义成本函数
function J=costFcn(state0,state1)
% S0=state0(1);
% v0=state0(2);
a0=state0(3);
j0=state0(4);
% S1=state1(1);
v1=state1(2);
a1=state1(3);
j1=state1(4);
J=abs(a1)*5+abs(j1)*10+abs(v1-8)*5;
end