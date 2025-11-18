function [lb,ub]=ObstacleBdy(Obs,point,Slim)
%% 基本参数获取
%确定障碍物个数
obsNum=length(Obs);
%% 对每个障碍物进行判断
ubs=zeros(obsNum,1);
lbs=zeros(obsNum,1);
for i=1:obsNum
    %当前时刻为t,即point(1);如果点S>lb && S<ub，则在障碍物中
    %插值获得当前t时刻障碍物的上下界限
    lbs(i)=interp1(Obs{i}(:,1),Obs{i}(:,2),point(1),[],Slim(2));
    if lbs(i)<point(2)
        lbs(i)=Slim(2);
    end
    ubs(i)=interp1(Obs{i}(:,1),Obs{i}(:,3),point(1),[],Slim(1));
    if ubs(i)>point(2)
        ubs(i)=Slim(1)-1;
    end
end
ub=min(lbs);
lb=max(ubs);


end