function state1=getNewState(state0,dt,Snew)
S0=state0(1);
v0=state0(2);
a0=state0(3);
%计算新的状态量
v1=(Snew-S0)/dt;
a1=(v1-v0)/dt;
j1=(a1-a0)/dt;
state1=[Snew,v1,a1,j1];
end