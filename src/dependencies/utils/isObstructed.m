%函数：判断一个ST图上的点是否在给定的障碍物空间当中（是否不可行）
%输入：Obs,元胞数组类型，i x 1,描述i个障碍物，每个元胞元素
%     为n x 3向量，分别为时间,下边界，上边界：[t,lb,ub],
%     n表示用n个点来表述这个障碍物
%输入：point,是ST图的一个点，[t,S]
%输出：flag表示是否在障碍物当中
function flag=isObstructed(Obs,point)
%% 基本参数获取
%确定障碍物个数
obsNum=length(Obs);
%预先给定flag值:0
flag=(1==0);
%% 对每个障碍物进行判断
for i=1:obsNum
    %当前时刻为t,即point(1);如果点S>lb && S<ub，则在障碍物中
    %插值获得当前t时刻障碍物的上下界限
    lb=interp1(Obs{i}(:,1),Obs{i}(:,2),point(1),[],inf);
    ub=interp1(Obs{i}(:,1),Obs{i}(:,3),point(1),[],-inf);
    if (point(2)>lb && point(2)<ub)
        flag=(1==1);
    end
end

end