% 获取车辆相对于当前edge的航向夹角
function relative_head = calcVehicleRelativeHeading(dummy)
    global params entity_dict %#ok'
    relative_head = 0;
    if isKey(entity_dict,dummy.laneID) && isKey(entity_dict,dummy.edgeID) 
        if entity_dict{dummy.edgeID}.laneNum > 1
            shape = entity_dict{dummy.laneID}.shape;
            distance = xy2dist(shape);
            lane_pos = dummy.lanePosition;
            idx = findIndexAfter(distance, lane_pos);
            if idx == 0
                idx = 1;
            elseif idx == length(distance)
                idx = length(distance) - 1;
            end
            p1 = shape(idx,:);
            p2 = shape(idx+1,:);
            vec = p2 - p1;
            lane_heading = atan2(vec(2),vec(1));
            relative_head = dummy.heading - lane_heading;
        end
    end
end



function k = findIndexAfter(v, x)
% FINDINDEXAFTER 判断数字x在递增向量v的哪个索引之后
% 输入：
%   v - 递增向量（1×n）
%   x - 待判断数字
% 输出：
%   k - 索引结果（x<v(1)返回0；x≥v(end)返回n；否则返回最大k满足v(k)≤x）

% 输入校验：确保v是递增向量
if ~issorted(v)
    error('向量v必须是递增向量！');
end

n = length(v);
if x < v(1)
    k = 0;
elseif x >= v(end)
    k = n;
else
    % discretize：将x分配到v的区间，返回区间索引
    % 区间定义：(-inf,v(1)], (v(1),v(2)], ..., (v(end),+inf)
    k = discretize(x, [-inf; v; inf]) - 1;
end
end