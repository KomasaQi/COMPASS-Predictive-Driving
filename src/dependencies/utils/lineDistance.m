function distance = lineDistance(p0, p1, p2)
    % 计算直线的方向向量
    v = p2 - p1;
    % 计算 p0 到直线的投影点
    t = dot(p0 - p1, v) / dot(v, v);
    projection = p1 + t * v;
    % 计算距离
    distance = norm(p0 - projection);
end
