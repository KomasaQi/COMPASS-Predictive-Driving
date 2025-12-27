function plotGraph(Graph,node_feat,edge_feat,figureID)
    if nargin < 2 || isempty(node_feat)
        node_feat = 'lanefeat'; % 车道特征，其他可选项还有freeends, laneno, speedlim, roadtype
    end
    if nargin < 3 || isempty(edge_feat)
        edge_feat = 'edgeside'; % 边特征，其他可选项还有edgeside
    end

    if nargin < 4 || isempty(figureID)
        figureID = 15;
    end
    global params %#ok
    if strcmpi(node_feat,'lanefeat')
        nodeColors = params.graph.vis.color_map_lanefeat(Graph);

    elseif strcmpi(node_feat,'freeends')
        nodeColors = params.graph.vis.color_map_freeends(Graph);

    elseif strcmpi(node_feat,'laneno')
        nodeColors = params.graph.vis.color_map_laneno(Graph);

    elseif strcmpi(node_feat,'speedlim')
        nodeColors = params.graph.vis.color_map_speedlim(Graph);

    elseif strcmpi(node_feat,'roadtype')
        nodeColors = params.graph.vis.color_map_roadtype(Graph);

    elseif strcmpi(node_feat,'vehspeed') || strcmpi(node_feat,'vehspd') || strcmpi(node_feat,'speed') || strcmpi(node_feat,'spd')
        nodeColors = params.graph.vis.color_map_vehspd(Graph);
    elseif strcmpi(node_feat,'vehocc') || strcmpi(node_feat,'occ')
        nodeColors = params.graph.vis.color_map_vehocc(Graph);
    elseif strcmpi(node_feat,'vehhead') || strcmpi(node_feat,'head') || strcmpi(node_feat,'heading')
        nodeColors = params.graph.vis.color_map_vehhead(Graph);
    elseif strcmpi(node_feat,'vehacc') || strcmpi(node_feat,'acc')
        nodeColors = params.graph.vis.color_map_vehacc(Graph);
    elseif strcmpi(node_feat,'vehego') || strcmpi(node_feat,'ego')
        nodeColors = params.graph.vis.color_map_vehego(Graph);
    elseif strcmpi(node_feat,'vehroute') || strcmpi(node_feat,'route') || strncmpi(node_feat,'int',3) 
        nodeColors = params.graph.vis.color_map_vehroute(Graph);
    elseif strcmpi(node_feat,'feasible') || strcmpi(node_feat,'drivable') || strncmpi(node_feat,'feas',4) 
        nodeColors = params.graph.vis.color_map_drivable(Graph);

    end
    
    if strcmp(edge_feat,'edgeside')
        edgeColors = params.graph.vis.color_map_edgeside(Graph);
    end

    figure(figureID),plot(Graph, ...
        'XData',Graph.Nodes.nodes_pos(:,1), ...
        'YData',Graph.Nodes.nodes_pos(:,2), ...
        'NodeColor',nodeColors, ...
        'EdgeColor',edgeColors)
    axis equal
end