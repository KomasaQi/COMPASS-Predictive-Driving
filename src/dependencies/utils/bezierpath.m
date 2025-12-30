function [path,t,cv]=bezierpath(state0,state1,tspan,Ts)
factor=0.1;
dist=norm(state0(1,:)-state1(1,:));
unitVec=zeros(2,2);
unitVec(1,:)=state0(2,:)/norm(state0(2,:));
unitVec(2,:)=state1(2,:)/norm(state1(2,:));
cve1=state0(1,:)+unitVec(1,:)*dist*2*factor;
cve2=state1(1,:)-unitVec(2,:)*dist*2*factor;
cvo=mean([cve1;cve2]);
cv=[...
    state0(1,:);
    state0(1,:)+unitVec(1,:)*dist*factor;
    cve1;
%     mean([cve1;cvo]);
%     cvo;
%     mean([cve2;cvo]);
    cve2;
    state1(1,:)-unitVec(2,:)*dist*factor;
    state1(1,:);
    ];

[path,t]=bezier(cv,tspan,Ts);



end

function [path,time]=bezier(cv,tspan,Ts)
time=(tspan(1):Ts:tspan(2))';
t=(time-tspan(1))/(tspan(2)-tspan(1));
order=size(cv,1);
path=zeros(length(t),2);
for i=1:length(t)
    B=zeros(1,order);
    for j=1:order
        B(j)=nchoosek(order-1,j-1).*(1-t(i)).^(order-j).*t(i).^(j-1);
    end
    path(i,:)=B*cv;
end
end