%% **************函数PSObestRoute*************************
%在给定的三维地图中寻找适应度函数最佳的点，使用PSO粒子群算法
%输入：map为结构体，包括x,y,z三个属性，x，y都是用meshgrid生成的
%     输入起点终点三坐标，指定中间控制点个数以及
%     使用的适应度函数，就可以实现PSO寻优
%输出：返回控制点以及路径散点
function [path,cv]=PSObestRoute(map,startpoint,endpoint,cvNum,fitnessfcn,algo)
%% 参数设置
maxbound=[min(map.x,[],'all'),min(map.y,[],'all'),min(map.z,[],'all');
          max(map.x,[],'all'),max(map.y,[],'all'),max([max(map.z,[],'all')+20,endpoint(3)+20])];

A = [];
b = [];
Aeq = [];
beq = [];

for i=cvNum
    lb = kron(ones(1,cvNum),maxbound(1,:));%设置参数下限
    ub = kron(ones(1,cvNum),maxbound(2,:));%设置参数上限
end
nvar=cvNum*3;%参数数量设置
nonlcon = [];
%% 参数识别寻优
if strcmp(algo,'ga')
    % options = optimoptions('ga','ConstraintTolerance',1e-6,'PlotFcn', @gaplotbestf,'UseParallel',true,'MaxGenerations',500);
    options = optimoptions('ga','ConstraintTolerance',1e-3,'UseParallel',true,'MaxGenerations',30);
    [x,~,~,~] = ga(@(param) getCurveFitness(param,map,fitnessfcn,startpoint,endpoint),nvar,A,b,Aeq,beq,lb,ub,[],options);
elseif strcmp(algo,'pso')
    % options = optimoptions('particleswarm','SwarmSize',100,'HybridFcn',@fmincon,'PlotFcn', @pswplotbestf,'UseParallel',true);
    options = optimoptions('particleswarm','SwarmSize',20,'HybridFcn',@fmincon,'UseParallel',true,'MaxIterations',30,'MaxTime',2);
    [x,~,~,~] = particleswarm(@(param) getCurveFitness(param,map,fitnessfcn,startpoint,endpoint),nvar,lb,ub,options);
elseif strcmp(algo,'fmincon')
    x0=lb+rand(size(ub)).*(ub-lb);
    for i = 1:cvNum
        x0((i-1)*(cvNum)+1) = 100;
    end
    x0 = [20 50 50 60 60 50 70 70 50];
    % options = optimoptions('fmincon','PlotFcn', @optimplotfval,'UseParallel',true);
    options = optimoptions('fmincon','UseParallel',true,'Algorithm','sqp','MaxIterations',200,'OptimalityTolerance',0.01);
    [x,~,~,~] = fmincon(@(param) getCurveFitness(param,map,fitnessfcn,startpoint,endpoint),x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
elseif strcmp(algo,'fminsearch')
    x0=lb+rand(size(ub)).*(ub-lb);
    for i = 1:cvNum
        x0((i-1)*(cvNum)+1) = 100;
    end
    x0 = [20 50 50 60 60 50 70 70 50];
    % options = optimset('PlotFcn', @optimplotfval,'UseParallel',true);
    options = optimset('UseParallel',true);
    [x,~,~,~] = fminsearch(@(param) getCurveFitness(param,map,fitnessfcn,startpoint,endpoint),x0,options);
end
%% 优化完成，组装CV点，输出结果
% 组装CV点
cv=zeros(cvNum+2,3);
cv(1,:)=startpoint;
cv(end,:)=endpoint;
for i=2:cvNum+1
    cv(i,:)=[x((i-2)*3+1),x((i-2)*3+2),x((i-2)*3+3)];
end
% 根据cv点生成path
path=fit3Dcurve(cv,[0 1],0.005,'notplot');
end
%% 子函数：适应度fitness
function fitness=getCurveFitness(param,map,fitnessfcn,startpoint,endpoint)
% 组装CV点
cvNum=(length(param)/3);
cv=zeros(cvNum+2,3);
cv(1,:)=startpoint;
cv(end,:)=endpoint;
for i=2:(cvNum+1)
    cv(i,:)=[param((i-2)*3+1),param((i-2)*3+2),param((i-2)*3+3)];
end
% 根据cv点生成path
path=fit3Dcurve(cv,[0 1],0.01,'notplot');
% 适应度计算
%首先判断是否与曲面相交，如果相交直接给适应度一个大值
% if isIntersect(map,path,1)
if 0
    fitness=1e15;
else  %如果不相交，计算适应度
    if strcmp(fitnessfcn,'curandlen')
        w1=6000;
        w2=1;
        [cur,tor]=curvature3q(path);
        len=xyzlength(path(:,1),path(:,2),path(:,3));
        risk = calcRisk(map,path,0.5);
        fitness=w1*sum((cur).^2+(tor).^2)+w2*len+risk*100;
        
    elseif strcmp(fitnessfcn,'cur')
        [cur,tor]=curvature3q(path);
        fitness=sum((cur).^2+(tor).^2);        
    elseif strcmp(fitnessfcn,'len')
        fitness=xyzlength(path(:,1),path(:,2),path(:,3));
    else
        fitness=1e15;
        fprintf('适应度函数名称错啦~检查一下哟\n');
    end
end
end


%% 子函数：根据cv点生成3D散点路径点
function path=fit3Dcurve(cv,tspan,Ts,plotfcn)
%要求cv是n x 3的向量，一共n个插值关键点
%最终获得一条过散点的3维空间的曲线
tseq=linspace(0,1,size(cv,1));
time=(tspan(1):Ts:tspan(2))';
t=time/(tspan(2)-tspan(1))-tspan(1);
path=[spline(tseq,cv(:,1),t),...
      spline(tseq,cv(:,2),t),...
      spline(tseq,cv(:,3),t)];
if strcmp(plotfcn,'showcurve')
    plot3(path(:,1),path(:,2),path(:,3),'r','linewidth',2);
    hold on
    grid on
    title('散点拟合曲线')
    scatter3(cv(:,1),cv(:,2),cv(:,3),100,'bs','markerfacecolor','g');
    legend('拟合曲线','控制点')
    hold off
end
end

%% 子函数：计算风险场
function risk = calcRisk(map,path,epsilon)
    z_interp=interp2(map.x,map.y,map.z,path(:,1),path(:,2));
    risk = sum(max((z_interp+epsilon)-path(:,3),0));
end

%% 子函数：判断曲线是否与曲面相交
%map同上，path为三维散点路径，n x 3，n个点
%epsilon为容差，表示要在曲面以上epsilon高度才算不相交
function flag=isIntersect(map,path,epsilon)
flag=(1==0);
for i=1:size(path,1)
    z_interp=interp2(map.x,map.y,map.z,path(i,1),path(i,2));
    if path(i,3)< (z_interp+epsilon)
        flag=(1==1);
        break 
    end
end
end

%% 子函数：计算曲线的曲率、挠率
%【加速版】计算曲线的曲率、挠率
function [cur, tor] = curvature3q(path)
    % 计算一阶导
    delta = 1 / size(path,1);
    f1 = gradient(path, delta);
    % 计算二阶导
    f2 = gradient(f1, delta);
    % 计算三阶导
    f3 = gradient(f2, delta);
    % 计算曲率的分子
    v = cross(f1, f2); % 一阶导与二阶导做外积
    % 计算曲率的分母
    c = sqrt(sum(v.^2, 1)); % 一阶导二阶导外积的模长
    d = sqrt(sum(f1.^2, 1)); % 一阶导模长
    % 计算曲率和挠率
    cur = c ./ (d.^3); % 曲率
    tor = dot(f3, v, 1) ./ c.^2; % 挠率
end


%% 子函数：求三维路径的路程长度
%根据路径x,y,z坐标序列求出路程总长度
function len=xyzlength(x,y,z)
distSequence=[0;cumsum(sqrt(diff(x).^2+diff(y).^2+diff(z).^2))];
len=distSequence(end);
end