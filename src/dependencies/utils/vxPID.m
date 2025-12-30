function ax=vxPID(e,ax0,Kp,Ki,Kd,Ts)
if length(e)==1
    e=[e;e;e];
end
k=length(e);
ax=min(5,ax0+(Kp*(e(k)-e(k-1))+Ki*e(k)+Kd*(e(k)-2*e(k-1)+e(k-2)))*Ts);
end