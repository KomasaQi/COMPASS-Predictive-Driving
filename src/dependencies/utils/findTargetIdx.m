%% 子函数：获取参考轨迹最近的点
function [idx,mindist]=findTargetIdx(pos,path)   
    dist = sum([(path(:,1)-pos(1)).^2,(path(:,2)-pos(2)).^2],2);
    [mindist,idx]=min(dist); %找到距离当前位置最近的一个参考轨迹点的序号和距离
end