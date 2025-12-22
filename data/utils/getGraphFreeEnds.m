% 输入的是一个Graph，输出的是该Graph中所有自由起始点或终止点的索引集合。
% 自由起始点定义为：该点的入度为0，出度大于0。
% 自由终止点定义为：该点的出度为0，入度大于0。
% fe_type: free end type, 必须是'start'或'end'
function [idxs,pos] = getGraphFreeEnds(G,fe_type)
    % global params %#ok
    pos = [];
    if strncmpi(fe_type,'start',1)
        idxs = find(G.indegree == 0 & G.outdegree > 0);

    elseif strncmpi(fe_type,'end',1)
        idxs = find(G.outdegree == 0 & G.indegree > 0);
    else
        error("fe_type必须是'start'或'end'");
    end
    if nargout > 1
        pos = G.Nodes.nodes_pos(idxs,:);
    end
end