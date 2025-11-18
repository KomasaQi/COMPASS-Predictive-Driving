%% 子函数：获取参考轨迹最近的点,其序号，以及偏移距离
function [p_min,idx,dev]=findTargetIdxDev(pos,path)   
    dist = sum([(path(:,1)-pos(1)).^2,(path(:,2)-pos(2)).^2],2);
    [~,idx]=min(dist); %找到距离当前位置最近的一个参考轨迹点的序号和距离
    p_min = path(idx,[1 2]);
    if idx == 1
        p_sec = path(2,[1 2]);
    elseif idx == size(path,1)
        p_sec = path(end-1,[1 2]);
    else
        if dist(idx+1)<dist(idx-1)
            p_sec = path(idx+1,[1 2]);
        else
            p_sec = path(idx-1,[1 2]);
        end
    end
    dev = lineDistance(pos, p_min, p_sec);
end

function distance = lineDistance(p0, p1, p2)
    % 计算直线的方向向量
    v = p2 - p1;
    % 计算 p0 到直线的投影点
    t = dot(p0 - p1, v) / dot(v, v);
    projection = p1 + t * v;
    % 计算距离
    distance = norm(p0 - projection);
end