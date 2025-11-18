% Dijkstra算法，输入P为图的邻接矩阵，n x n
% 输入起点和终点节点的代号数字
% 返回最短距离
function [distMin,route]=dijkstra(P,indStart,indEnd)
juncNum=size(P,1);
%起点和终点
%% 创建辅助矩阵
%储存完成识别最短路径的节点矩阵
S=zeros(1,juncNum);
%储存从起始点到其他点最短路径序列的数组
Road=cell(1,juncNum);
%% 迭代计算
%第一步运算
S(indStart)=inf;%给对应节点编号位置赋值inf表示该节点已被计算
U=P(indStart,:);
for i=1:juncNum
Road{i}=indStart;
end
for i=1:juncNum-1
    [~,idx]=min(S+U);%求出未计算最短点中最短路径的节点编号
    S(idx)=inf;
    [U,index]=min([U;U(idx)+P(idx,:)]); %更新最短距离
    UpdateSequ=find(index==2);
    for j=1:length(UpdateSequ) %更新最短路径序列
        Road{UpdateSequ(j)}=[Road{idx},idx];
    end
end
for i=1:juncNum
    if i==indStart
        continue;
    end
    Road{i}=[Road{i},i];
end
%% 输出结果
distMin=U(indEnd);
route=Road{indEnd};
disp(['从节点' num2str(indStart) '到节点' num2str(indEnd)...
    '的最短路程为' num2str(distMin) ',路径序列为：'...
    num2str(route)]);
end