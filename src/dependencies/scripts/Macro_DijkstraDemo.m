%带权有向图见word文档全局路径规划内容
%% 创建图邻接矩阵
%共7个节点，12条边
P=[...
    0   12  inf inf inf 16  14;
    12  0   10  inf inf 7   inf;
    inf 10  0   3   5   6   inf;
    inf inf 3   0   4   inf inf;
    inf inf 5   4   0   2   8;
    16  7   6   inf 2   0   9;
    14  inf inf inf 8   9   0;
    ];
juncNum=size(P,1);
%起点和终点
indStart=4;
indEnd=1;
%% 创建辅助矩阵
%储存完成识别最短路径的节点矩阵
S=zeros(1,juncNum);
%储存从起始点到其他点最短路径序列的数组
Road=cell(1,juncNum);
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
distMin=U(indEnd);
disp(['从节点' num2str(indStart) '到节点' num2str(indEnd)...
    '的最短路程为' num2str(distMin) ',路径序列为：'...
    num2str(Road{indEnd})]);





