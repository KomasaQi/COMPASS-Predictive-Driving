% 将车辆特征编码进有向图中，增加新的车辆相关的节点特征
% 提取到动态特征包括：
% 1. 占据概率： 0~1的浮点数，代表该节点被车辆占据的概率
% 2. 车辆类型： 0~14的整数，分别对应不同的车辆类型
% 3. 车辆速度： 实际速度值 m/s
% 4. 车辆加速度：实际加速度值 m/s2
% 5. 车辆相对航向角：相对于当前车道航向的角度偏差，右手定则 rad
% 6. 车辆的意图：分别对应cruise exit merge 

function G_emb = embbedVehicles(G_local,ego,vehicleDummies)
    vehDummies = [{ego},vehicleDummies];
    global params %#ok
    nodes_pos = [G_local.Nodes.nodes_pos,G_local.Nodes.road_type.*params.graph.geometry.highway_height];
    mapTree = KDTreeSearcher(nodes_pos);
    vehMask = zeros(size(nodes_pos,1),1);
    vehTypeMask = zeros(size(nodes_pos,1),1);
    vehSpdMask = zeros(size(nodes_pos,1),1);
    vehAccMask = zeros(size(nodes_pos,1),1);
    vehHeadMask = zeros(size(nodes_pos,1),1);
    vehEgoMask = zeros(size(nodes_pos,1),1);
    vehRouteMask = zeros(size(nodes_pos,1),1);
    for i = 1:length(vehDummies)
        shape_square = getVehicleShape(vehDummies{i});
        veh_pos = [mean(shape_square) calcVehicleHeight(vehDummies{i})];
        [idxs,distance] = knnsearch(mapTree,veh_pos,'k',params.graph.occ.searchPt);
        idxs = idxs(distance < params.graph.occ.searchRange);
        vehMask_2d = computeVehicleOccupancyMask(nodes_pos(idxs,[1 2]), shape_square, ...
        'SmoothType', 'gaussian', ...
        'LongitudinalRadius', params.graph.occ.longitudinalRadius, ...  % 纵向半径更大
        'LateralRadius', params.graph.occ.lateralRadius,  ...           % 横向半径更小
        'LongitudinalSigma', params.graph.occ.longitudinalSigma,...     % 纵向标准差
        'LateralSigma', params.graph.occ.lateralSigma);                 % 横向标准差
        
        % valid_mask = 
        vType = find(strcmp(params.sumo_vehicle_lib.keys,vehDummies{i}.vType));
        if i == 1
            vehEgoMask(idxs) = vehEgoMask(idxs) + vehMask_2d;
        else
            vehMask(idxs) = vehMask(idxs) + vehMask_2d;

        end
        vehTypeMask(idxs) = vehTypeMask(idxs) + (vehMask_2d > 0.2)*vType;
        vehSpdMask(idxs) = vehSpdMask(idxs) + (vehMask_2d > 0.2)*vehDummies{i}.speed;
        vehAccMask(idxs) = vehAccMask(idxs) + (vehMask_2d > 0.2)*vehDummies{i}.acc;
        vehHeadMask(idxs) = vehHeadMask(idxs) + (vehMask_2d > 0.2)*calcVehicleRelativeHeading(vehDummies{i});
        vehRouteMask(idxs) = vehRouteMask(idxs) + (vehMask_2d > 0.2)*getRouteFeature(vehDummies{i});
        
        
        
    end
    vehTypeMask(vehTypeMask > length(params.sumo_vehicle_lib.keys)) = 0; % 如果多车在一个位置存在重叠，就归零


    nodesTable = G_local.Nodes;
    nodesTable.vehMask = vehMask;
    nodesTable.vehTypeMask = vehTypeMask;
    nodesTable.vehSpdMask = vehSpdMask;
    nodesTable.vehAccMask = vehAccMask;
    nodesTable.vehHeadMask = vehHeadMask;
    nodesTable.vehEgoMask = vehEgoMask;
    nodesTable.vehRouteMask = vehRouteMask;
    nodesTable.nodes_pos = centralize2DPoints(nodesTable.nodes_pos,ego.pos([1 2]),ego.heading);
    G_emb = digraph(G_local.Edges,nodesTable);
end

function pts_rot = centralize2DPoints(pts,pos,heading)
    pts_rot = (pts - pos)*[cos(heading) -sin(heading);sin(heading) cos(heading)];

end

function routeFeat = getRouteFeature(dummy)
    global params %#ok
    if strcmpi(dummy.vehID,params.vehicleID) % 是主车，从仿真文件名字判断
        if contains(params.sumo_file_name,'exit') 
            routeFeat = params.graph.intention.exit;
        elseif contains(params.sumo_file_name,'merge') 
            routeFeat = params.graph.intention.merge;
        else
            routeFeat = params.graph.intention.cruise;
        end
    else % 是其他车，从车辆名字判断
        if contains(dummy.vehID,'exit')
            routeFeat = params.graph.intention.exit;
        elseif contains(dummy.vehID,'merge')
            routeFeat = params.graph.intention.merge;
        else
            routeFeat = params.graph.intention.cruise;
        end
    end

end


% 返回的是 4 x 3的矩阵，表示FL FR RR RL四个角点
function shape_square = getVehicleShape(dummy)
    head = dummy.heading_cos_sin;
    pos = dummy.pos(1:2);
    W = dummy.width;
    L = dummy.length;
    left = rot2Dvec90deg(head,'left');
    shape_square = pos + left*W/2.*[1 -1 -1 1]' - head*L.*[0 0 1 1]';
end