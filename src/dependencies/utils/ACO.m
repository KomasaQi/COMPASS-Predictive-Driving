% ACO蚁群算法，输入P为图的邻接矩阵，n x n
% 输入起点和终点节点的代号数字
% 返回最短距离
function [dist_min,path_opt]=ACO(P,node_start,node_end,plotfcn)

%% 蚁群相关定义
%蚁群相关定义
n=size(P,1);    %节点数量
m=40; %蚂蚁数量
alpha=1.5;      %信息素重要程度因子
beta=2;         %启发函数重要程度因子
rho=0.01;        %信息素挥发因子
Q=2;            %常数
Info0=0.01;      %初始信息素浓度

%迭代过程中，相关参数初始化定义
iter=1;        %迭代次数初值
iter_max=100;  %最大迭代次数
Route_best = cell(iter_max,1); %各代的最佳路径
Length_best=zeros(iter_max,1); %各代的最佳路径长度
Length_ave=zeros(iter_max,1);  %各代路径的平均长度

%信息素浓度矩阵
Info=zeros(n);
for i =1:n
    for j =1:n
        if P(i,j)~=0 && ~isinf(P(i,j))
            Info(i,j)=Info0;
        end
    end
end
%启发因子矩阵
Inspire=Q./P;
for i=1:n
    Inspire(i,i)=0;
end
if strcmp(plotfcn,'plotstep')
%% 绘图展示结果 
figure;hold on
end
%% 迭代寻找最佳路径
while iter<=iter_max
   %初始化空间存储每一只蚂蚁的路径和总距离
    route=cell(m,1) ;
   Length=zeros(m,1);
   %% 逐个蚂蚁路径选择
   for i=1:m
      %逐个节点路径选择
      neighbor=cell(0);
      position=node_start;
      path=position;
      dist=0;
      while ~ismember(node_end,path) %当路径表里包括终点时，该蚂蚁完成路径寻找，退出循环
         % 寻找邻近节点 
         neighbor=find(P(position,:)~=inf);
         
         % 删除已经访问过的临近节点
         idx=[];
         for k=1:length(neighbor)
             if ismember(neighbor(k),path)
                 idx(end+1)=k;
             end
         end
         neighbor(idx)=[];
         
         %判断是否进入死胡同，若是，直接返回到起点，重新寻路
         if isempty(neighbor)
             neighbor = cell(0);
             position=node_start;
             path=position;
             dist=0;
             continue;
         end
         
         % 计算下一个节点的访问概率
         posibility=zeros(size(neighbor));
         for k =1:length(posibility)
             posibility(k)= Info(position,neighbor(k))^alpha*...
                 Inspire(position,neighbor(k))^beta;
         end
         posibility=posibility/sum(posibility);
         
         %轮盘赌法选择下一个访问节点
         Pc=[0 cumsum(posibility)];
         randnum= rand;
         for k=1:length(Pc)-1
             if randnum > Pc(k) && randnum< Pc(k+1)
                 next_node=neighbor(k);
             end
         end
         
         %计算单步距离，更新总距离
         dist = dist+P(position,next_node);
         
         %更新下一步的目标节点及路径集合
         position = next_node;
         path(end+1)=position;
      end
      %存放第i只蚂蚁的累计距离以及对应路径
      Length(i)=dist;
      route{i}=path;
   end
   %% 计算这一代的m只蚂蚁中最短距离及对应路径
   if iter ==1
       [min_length,min_index]=min(Length);
       Length_best(iter)=min_length;
       Length_ave(iter)=mean(Length);
       Route_best{iter}=route(min_index,1);
   else
       [min_length,min_index]=min(Length);
       Length_best(iter)=min(min_length,Length_best(iter-1));
       Length_ave(iter)=mean(Length);
       if Length_best(iter)==min_length
           Route_best{iter}=route(min_index,1);
       else
           Route_best{iter}=Route_best(iter-1);
       end
   end
    
   %% 更新信息素
   %计算每一条路径上经过的蚂蚁留下的信息素

   %逐个蚂蚁计算
   for i=1:m
       %逐个节点计算
       for j=1:length(route{i})-1
           n_start=route{i}(j);
           n_end=route{i}(j+1);
           Info(n_start,n_end)=Info(n_start,n_end)+Inspire(n_start,n_end);
           Info(n_end,n_start)=Info(n_start,n_end);
       end
   end
   %考虑挥发因子，更新信息素
   Info=Info.*(1-rho);
   
   if strcmp(plotfcn,'plotstep')
    plot(1:iter,Length_best(1:iter),'b',1:iter,Length_ave(1:iter),'r')
    legend('最短距离','平均距离');
    xlabel('迭代次数');
    ylabel('距离');
    title('各代最短距离与平均距离对比');
    pause(0.01)
    end
   iter=iter+1;
   
end
%最优路径
[dist_min,idx]=min(Length_best);
path_opt=Route_best{idx};
%% 绘图展示结果 
if strcmp(plotfcn,'plot')
figure
plot(1:iter_max,Length_best,'b',1:iter_max,Length_ave,'r')
legend('最短距离','平均距离');
xlabel('迭代次数');
ylabel('距离');
title('各代最短距离与平均距离对比');

disp(['从节点' num2str(node_start) '到节点' num2str(node_end)...
    '的最短路程为' num2str(dist_min) ',路径序列为：'...
    num2str(path_opt{1:end})]);
end
if strcmp(plotfcn,'plotstep')
disp(['从节点' num2str(node_start) '到节点' num2str(node_end)...
    '的最短路程为' num2str(dist_min) ',路径序列为：'...
    num2str(path_opt{1:end})]);
end

end





