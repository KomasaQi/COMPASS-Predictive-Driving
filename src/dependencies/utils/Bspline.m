function [path,u]=Bspline(cv,tspan,Ts,flag,plotfcn,k)
if nargin < 2 || isempty(tspan)
    tspan = [0 1];
end
if nargin < 3 || isempty(Ts)
    Ts = 0.01;
end
if nargin < 4 || isempty(flag)
    flag = 2;
end
if nargin < 5 || isempty(plotfcn)
    plotfcn = 'noshowbase';
end
if nargin < 6 || isempty(k)
    k=4;         %k阶、k-1次B样条
end
ptNum = round((tspan(2) - tspan(1))/Ts);
time=linspace(tspan(1),tspan(2),ptNum)';
u=(time-tspan(1))/(tspan(2)-tspan(1));
n=size(cv,1)-1;  %n为控制点的个数，从0开始计数
Bik=zeros(n+1,1);
if strcmp(plotfcn,'showbase')
    showbase=1;
    base=zeros(length(time),size(cv,1));
else 
    showbase=0;
end
%flag==1 均匀B样条，flag==2 准均匀B样条
if flag==1 %均匀B样条
    NodeVector=linspace(0,1,n+k+1); %节点矢量
elseif flag==2 %准均匀B样条
    NodeVector=U_quasi_uniform(n,k-1); %节点矢量
end
if flag==2
    path=zeros(length(u),2);
    for i=1:length(u)-1
        for j=0:n
            Bik(j+1)=BaseFunction(j,k-1,u(i),NodeVector);
        end
        path(i,:)=Bik'*cv;
        if showbase
             base(i,:)=Bik';
        end
    end
    if showbase
        base(end)=1;
        figure
        plot(linspace(0,1,length(time)),base);
        title(['非均匀B样条曲线基函数:',num2str(k),'阶(',num2str(k-1),'次)']);
        xlabel('参数 t');
        ylabel('基');
    end
    path(end,:)=cv(end,:);
elseif flag==1
    u=linspace((k-1)/(n+k+1),(n+2)/(n+1+k),length(time));
    path=zeros(length(u),2);
    for i=1:length(u)
        for j=0:n
            Bik(j+1)=BaseFunction(j,k-1,u(i),NodeVector);
        end
        path(i,:)=Bik'*cv;
        if showbase
             base(i,:)=Bik';
        end
    end
    if showbase
        figure
        plot(linspace(0,1,length(time)),base);
        title('均匀B样条曲线基函数');
        xlabel('参数 t');
        ylabel('基');
    end
end

end

function NodeVector=U_quasi_uniform(n,k)
    %准均匀B样条的节点向量计算，共n+1个控制节点，k次B样条，k+1阶
    NodeVector=zeros(1,n+k+2);
    piece=n-k+1;   %曲线的段数
    if piece==1
        for i = k+2 : n+k+2
            NodeVector(i)=1;
        end
    else
        flag=1; %不止一段曲线时
        while flag~=piece
            NodeVector(k+flag+1)=NodeVector(k+flag)+1/piece;
            flag=flag+1;
        end
        NodeVector(n+2 : n+k+2) = 1; %节点向量前面和后面有k+1个重复值
    end
end

function Bik_u=BaseFunction(i,k,u,NodeVector)
if k==0 %0次B样条
    if u>=NodeVector(i+1) && u< NodeVector(i+2)
        Bik_u=1;
    else
        Bik_u=0;
    end
else
    Length1=NodeVector(i+k+1)-NodeVector(i+1);
    Length2=NodeVector(i+k+2)-NodeVector(i+2);
    if Length1==0 %规定0/0=0
        Length1=1;
    end
    if Length2==0
        Length2=1;
    end
    Bik_u=(u-NodeVector(i+1))/Length1*BaseFunction(i,k-1,u,NodeVector)...
        +(NodeVector(i+k+2)-u)/Length2*BaseFunction(i+1,k-1,u,NodeVector);
        
end
end