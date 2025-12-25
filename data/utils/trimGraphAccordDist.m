% 根据距离远近来切取一个有向图子图
% G_main是有向图全图，我们需要根据kdtree(3d)和给定的
function G_local = trimGraphAccordDist(ego_dummy)

    global G_main mainTree params %#ok
    front_dist = params.graph.submap.range.front;
    back_dist = params.graph.submap.range.back;
    dev = (front_dist - back_dist)/2;
    range = back_dist + dev;
    % 首先计算所有的
    nodePos3D = mainTree.X;
    center = [ego_dummy.pos(1:2) + dev*ego_dummy.heading_cos_sin calcVehicleHeight(ego_dummy)];
    
    dist = sqrt(sum((nodePos3D - center).^2,2));

    % 找到所有在范围内的节点
    inRange = find(dist <= range);

    % 构建子图
    G_local = G_main.subgraph(inRange);


end