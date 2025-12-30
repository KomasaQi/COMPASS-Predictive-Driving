function K=RicattiForLQR(A,B,Q,R)
iter_max=500;
P0=Q;
P=zeros(size(Q));
iter=0;
while (max(max(abs(P0-P)))>eps)
    iter=iter+1;
    if iter==iter_max
        break
    end
    P= Q + A'*P0*A - (A'*P0*B)*((R+B'*P0*B)\(B'*P0*A));
    P0=P;
end
K=(B'*P*B + R)\(B'*P*A);
end


