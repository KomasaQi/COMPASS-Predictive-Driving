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
function [route,Spast,ListNum]=DPforSTgraph1(initstate,tseq,dS,Slim,constrain,Obs,costFcn)
clearList=zeros(1200,1);
%预先根据运动约束计算可行域范围
dt=tseq(2)-tseq(1);
%定义车辆初始状态
state=initstate;
%上一步记录的位置Spast
ListNum=1;
Spast=zeros(1200,length(tseq)+length(initstate)+1,1);
Spast(1,1)=state(1);% Spast{1}.path=state(1);%最优路径
Spast(1,length(tseq)+1:end-1)=state;% Spast{1}.state=state;%该点的状态
Spast(1,end)=0;% Spast{1}.cost=0;
%% 第一层循环，从tseq的第2个点到最后一个时间点
for i=2:length(tseq)
    t=tseq(i);
    %寻找当前时刻可行域,可行域为[t,Snext]
    Snext=findValidZoneRange(dS,t-dt,dt,Spast(1,length(tseq)+1:end-1),Spast(ListNum,length(tseq)+1:end-1),constrain,Obs,'next');
    %对S搜寻范围进行限制
    Snext(Snext>Slim(2)| Snext<Slim(1))=[];
    %当前点的记录，最优路径和该点状态
    Scurrent=zeros(1200,length(tseq)+length(initstate)+1,1);
    currentListNum=length(Snext);
    %% 第二层循环，遍历Snext的每个可行点
    for k=1:currentListNum
        Snew=Snext(k);
         %存储代价的空间
        J=zeros(ListNum,1);
        clearNum=0;
        clearList(1:end)=zeros(1200,1);
     %% 第三层循环，Snext的每一个可行点去遍历Spast中符合要求的点
        for n=1:ListNum
        %获取该点的状态量
        state1=getNewState(Spast(n,length(tseq)+1:end-1),dt,Snew);
            if ~min([state1(2:4)<constrain(:,2)']) | ~min(state1(2:4)>constrain(:,1)') 
                J(n)=inf;
            else
                J(n)=costFcn(Spast(n,length(tseq)+1:end-1),state1)+Spast(n,end);
            end
        end
        %找到Snew点与所有之前有记录的点的最小代价及编号
        [minCost,minIdx]=min(J);
        if isinf(minCost)
            clearNum=clearNum+1;
            clearList(clearNum)=k;
        end
        Scurrent(k,end)=minCost;
        Scurrent(k,length(tseq)+1:end-1)=getNewState(Spast(minIdx,length(tseq)+1:end-1),dt,Snew);
        Scurrent(k,1:length(tseq))=[Spast(minIdx,1:i-1),Snew,zeros(1,length(tseq)-i)];
    end
    if clearNum~=0
        differ=setdiff(1:currentListNum,clearList(1:clearNum));
        Scurrent(1:length(differ),:)=Scurrent(differ,:);
    else
        differ=1:currentListNum;
    end
    Spast=Scurrent;
    ListNum=length(differ);
     disp([num2str(i/length(tseq))])
end
clearNum=0;
for i=1:ListNum
    if isinf(Spast(i,end))
        clearNum=clearNum+1;
        clearList(clearNum)=i;
    end
end
if clearNum~=0
        differ=setdiff(1:ListNum,clearList(1:clearNum));
        Spast(1:length(differ),:)=Spast(differ,:);
else
    differ=1:ListNum;
end
    ListNum=length(differ);
Cost=zeros(1,ListNum);
for n=1:ListNum
Cost(n)=Spast(n,end);
end
[~,minIdx]=min(Cost);
if size(tseq,1)==1
    tseq=tseq';
end
route=[tseq,Spast(minIdx,1:length(tseq))'];

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

