% 根据connection_dict中的连接关系连接两个edge的Graph表示，返回一个新的包含新连接的Graph
% 输入的是两个Graph的集合，分别是源Graph和目标Graph的集合。
function G_comb = seamSubGraphs(G_srcs,G_tgts,proxy_dist)
    if nargin < 3 || isempty(proxy_dist)
        proxy_dist = 50.0; % 认为start点集和end点集最远允许距离
    end
    global entity_dict connection_dict lane_to_connection_dict lane_from_connection_dict to_connection_dict %#ok
    global params %#ok
    
    % 如果源图和目标图包含多个子图，我们将其先融合
    G_src = catEdgeGraphs(G_srcs);
    G_tgt = catEdgeGraphs(G_tgts);
    old_total_node_num = size(G_src.Nodes,1) + size(G_tgt.Nodes,1);

    % 从目标图中所有自由起始点的集合，和源图中所有自由终止点的集合中，筛选出空间距离小于一定范围的集合
    [start_idxs,start_poss] = getGraphFreeEnds(G_tgt,'start');
    [end_idxs,end_poss] = getGraphFreeEnds(G_src,'end');

    [starter_idxs, ender_idxs] = matchFreeEnds(start_poss, end_poss, proxy_dist);
    starter_poss = end_poss(starter_idxs, :);
    ender_poss = start_poss(ender_idxs,:);

    G_old = catEdgeGraphs({G_src, G_tgt});
    starter_idxs = end_idxs(starter_idxs);
    ender_idxs = start_idxs(ender_idxs) + size(G_src.Nodes,1);

    s_idxs = sortVector(starter_poss);
    e_idxs = sortVector(ender_poss);

    starter_poss = starter_poss(s_idxs,:);
    ender_poss = ender_poss(e_idxs,:);

    starter_idxs = starter_idxs(s_idxs);
    ender_idxs = ender_idxs(e_idxs);


    [src, tgt, Weight,insertNodesTable] = genJunctionGraph(...
        starter_poss, ender_poss, starter_idxs, ender_idxs, old_total_node_num);
    
    EndNodes = [src,tgt];
    edgeTable = vertcat(G_old.Edges,table(EndNodes,Weight));

    nodeTable = vertcat(G_old.Nodes,insertNodesTable);
    G_comb = digraph(edgeTable,nodeTable);

    


    





end