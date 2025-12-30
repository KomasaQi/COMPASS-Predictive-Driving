%% 函数curvature()%%%%%%%%%%%%%%%%%%%
%输入：x,y，分别为n维向量，表示一条轨迹的散点
%输出：k，表示每一点的曲率，n维向量，维度与x向量相同
%方法及局限：三点共圆法求曲率半径，倒数为曲率，
%           缺点是第一个点和最后一点曲率无法求出，故使用
%           k(1)=k(2),k(end)=k(end-1)近似
function k=curvature_xy(x,y)
%三点求曲率
%用三点构成三角形，余弦定理求一个角cosA，对边a
%曲率半径0.5*a/sin(A)，曲率为曲率半径的倒数。
len=length(x);
k=zeros(size(x));
for i=2:len-1
    A=[x(i),y(i)];
    B=[x(i-1),y(i-1)];
    C=[x(i+1),y(i+1)];
    BC=C-B;
    BA=A-B;
    bc=rotate(BC,-cart2pol(BA(1),BA(2)));
    a=Distance(B,C);
    b=Distance(A,C);
    c=Distance(A,B);
    cosA=(b^2+c^2-a^2)/(2*b*c);
    alpha=real(acos(cosA));
    k(i)=sign(cart2pol(bc(1),bc(2)))*sin(alpha)/(0.5*a);
end
k(1)=k(2);
k(end)=k(end-1);
end

function vec1 = rotate(vec0, th)
vec1 = [cos(th), -sin(th); sin(th), cos(th)] * vec0';
vec1 = vec1';
end

function dist = Distance(x1, x2)
dist = norm(x1 - x2);
end