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