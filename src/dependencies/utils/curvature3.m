%% 计算曲线的曲率、挠率
function [cur,tor]=curvature3(x,y,z)
if(size(x,1)==1)
    f=[x;y;z];
else
    f=[x';y';z'];
end
delta=1/length(x);
f1=(gradient(f)./delta)'; %一阶导
f2=(gradient(f1')./delta)'; %二阶导
f3=(gradient(f2')./delta)'; %三阶导
% 曲率 挠率
v=cross(f1,f2,2); %一阶导与二阶导做外积
e=dot(f3,v,2);    %（r',r'',r'''）混合积
c=zeros(length(x),1); %定义矩阵c储存一阶导二阶导叉乘模长
d=c;                 %定义d储存一阶导模长
for i=1:length(x)
   c(i) = norm(v(i,:));  %一阶导二阶导外积的模长
   d(i) = norm(f1(i,:)); %一阶导模长
end
cur=c./(d.^3); %曲率
tor=e./c.^2;   %挠率  torsion
end