function valid=findValidZone(dS,t,dt,state,constrain,Obs,option)
 %运动学限制
vlim=constrain(1,:);
alim=constrain(2,:);
jlim=[max([constrain(3,1);-40]),min([constrain(3,2),40])];  
%状态
S=state(1);
v=state(2);
a=state(3);
%初步的可行域是根据速度限制确定的
vvalid=[ceil(dt*vlim(1)/dS),floor(dt*vlim(2)/dS)];
%根据加速度约束对初步可行域进行判断
avalid=[ceil(dt*(v+alim(1)*dt)/dS),floor(dt*(v+alim(2)*dt)/dS)];
%根据加加速度约束建立可行域
jvalid=[ceil(dt*(v+(a+jlim(1))*dt)/dS),floor(dt*(v+(a+jlim(2))*dt)/dS)];
valid_temp=[vvalid;avalid;jvalid];
if strcmp(option,'next')
    valid=S+dS*(max(valid_temp(:,1)):min(valid_temp(:,2)));
elseif strcmp(option,'last')
    valid=S-dS*(max(valid_temp(:,1)):min(valid_temp(:,2)));
end
clearList=zeros(1,length(valid));
for i=1:length(valid)
    clearList(i)=isObstructed(Obs,[t+dt,valid(i)]);
end
clearList=find(clearList==1);
valid(clearList)=[];
end
