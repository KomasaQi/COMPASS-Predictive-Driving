% 将多个子图变成一张大图，并不会增加任何新的连接。新的大图中，子图之间是独立的。
% 输入的G_srcs是一个cell数组，内部可以包含1~N张图，但是必须要包含相同的节点和边特征结构
function G_cat = catEdgeGraphs(G_srcs)
    global entity_dict connection_dict lane_to_connection_dict lane_from_connection_dict to_connection_dict %#ok
    global params %#ok
    
    if isa(G_srcs,"cell")
        if length(G_srcs) == 1 % 如果只有
            G_cat = G_srcs{1};
        else % 如果确实包含多张图
            Nodes_set = cell(length(G_srcs),1);
            EndNodes_set = cell(length(G_srcs),1);
            Weights_set = cell(length(G_srcs),1);
            % 循环收集一下所有的节点和边
            exist_node_num = 0;
            for i = 1:length(G_srcs)
                Nodes_set{i} = G_srcs{i}.Nodes;
                EndNodes_set{i} = G_srcs{i}.Edges.EndNodes + exist_node_num;
                Weights_set{i} = G_srcs{i}.Edges.Weight;
                exist_node_num = exist_node_num + size(G_srcs{i}.Nodes,1);
            end
            nodeTable = vertcat(Nodes_set{:});
            new_edges = vertcat(EndNodes_set{:});  
            new_weights = vertcat(Weights_set{:});  
            G_cat = digraph(new_edges(:,1),new_edges(:,2),new_weights,nodeTable);
            
        end
    else
        error("输入的G_srcs必须是一个cell数组,当前数据类型为%s",class(G_srcs));
    end

end