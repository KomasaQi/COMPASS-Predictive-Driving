%函数：给出一条满足给定成本函数下最小成本的路径route
%      并不要求最后一个点的S坐标固定
%输入：initstate,当前车辆的状态，[S,v,a,jerk]
%输入：tseq,离散时间序列,要求间隔一致
%输入：dS,路程的离散度，m
%输入：Slim,搜索路程范围的限制，Slim=[lb,ub]
%输入：constrain，运动约束，形式如下：[vmin vmax;amin amax;jerkmin jerkmax]
%      3 x 2的矩阵
%输入：Obs,元胞数组类型，i x 1,描述i个障碍物，每个元胞元素
%     为n x 3向量，分别为时间,下边界，上边界：[t,lb,ub],
%     n表示用n个点来表述这个障碍物
%输出：给定成本函数下最小成本的路径route,[tseq,Sopt]
function [route,Spast]=DPforSTgraph(initstate,tseq,dS,Slim,constrain,Obs,costFcn)
%预先根据运动约束计算可行域范围
dt=tseq(2)-tseq(1);
%定义车辆初始状态
state=initstate;
%上一步记录的位置Spast
Spast{1}.path=state(1);%最优路径
Spast{1}.state=state;%该点的状态
Spast{1}.cost=0;
%% 第一层循环，从tseq的第2个点到最后一个时间点
for i=2:length(tseq)
    t=tseq(i);
    %上一时刻有记录的点数：
    ListNum=length(Spast);
    %寻找当前时刻可行域,可行域为[t,Snext]
    Snext=findValidZoneRange(dS,t-dt,dt,Spast{1}.state,Spast{end}.state,constrain,Obs,'next');
    %对S搜寻范围进行限制
    Snext(Snext>Slim(2)| Snext<Slim(1))=[];
    %当前点的记录，最优路径和该点状态
    Scurrent=cell(length(Snext),1);
    %% 第二层循环，遍历Snext的每个可行点
    for k=1:length(Snext)
        Snew=Snext(k);
         %存储代价的空间
        J=zeros(ListNum,1);
        clearList=[];
     %% 第三层循环，Snext的每一个可行点去遍历Spast中符合要求的点
        for n=1:ListNum
        %获取该点的状态量
        state1=getNewState(Spast{n}.state,dt,Snew);
            if ~min([state1(2:4)<constrain(:,2)']) | ~min(state1(2:4)>constrain(:,1)') 
                J(n)=inf;
            else
                J(n)=costFcn(Spast{n}.state,state1)+Spast{n}.cost;
            end
        end
        %找到Snew点与所有之前有记录的点的最小代价及编号
        [minCost,minIdx]=min(J);
        if isinf(minCost)
            clearList=[clearList,k];
        end
        Scurrent{k}.cost=minCost;
        Scurrent{k}.state=getNewState(Spast{minIdx}.state,dt,Snew);
        Scurrent{k}.path=[Spast{minIdx}.path,Snew];
    end
    if ~isempty(clearList)
        Scurrent(clearList)=[];
    end
    Spast=Scurrent;
    disp([num2str(i/length(tseq))])
end
clearList=[];
for i=1:length(Spast)
    if isinf(Spast{i}.cost)
        clearList=[clearList i];
    end
end
if ~isempty(clearList)
    Spast(clearList)=[];
end

Cost=zeros(1,length(Spast));
for n=1:length(Spast)
Cost(n)=Spast{n}.cost;
end
[~,minIdx]=min(Cost);
if size(tseq,1)==1
    tseq=tseq';
end
route=[tseq,Spast{minIdx}.path'];

end



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

