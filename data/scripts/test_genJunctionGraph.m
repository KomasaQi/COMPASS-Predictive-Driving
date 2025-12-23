idset = {'96615334#0-AddedOffRampEdge','135267565','96615334#1','135267593','96615334#2-AddedOnRampEdge','96615334#0'}; % 1连2
proxy_dist = 25;
% Junction1
G1 = genEdgeGraph(idset{1});
G2 = genEdgeGraph(idset{2});
G3 = genEdgeGraph(idset{3});
G_comb1 = seamSubGraphs({G1},{G2,G3},proxy_dist);

% Junction2
G4 = genEdgeGraph(idset{4});
G5 = genEdgeGraph(idset{5});
G_comb2 = seamSubGraphs({G_comb1,G4},{G5},proxy_dist);

% Junction0
G6 = genEdgeGraph(idset{6});
G_comb = seamSubGraphs({G6},{G_comb2},proxy_dist);


% 画图可视化
% figure,plot(G_comb,'XData',G_comb.Nodes.nodes_pos(:,1),'YData',G_comb.Nodes.nodes_pos(:,2),'NodeColor',params.graph.vis.color_map_lanefeat(G_comb))
% figure,plot(G_comb,'XData',G_comb.Nodes.nodes_pos(:,1),'YData',G_comb.Nodes.nodes_pos(:,2),'NodeColor',params.graph.vis.color_map_freeends(G_comb))
% figure,plot(G_comb,'XData',G_comb.Nodes.nodes_pos(:,1),'YData',G_comb.Nodes.nodes_pos(:,2),'NodeColor',params.graph.vis.color_map_laneno(G_comb))
% figure,plot(G_comb,'XData',G_comb.Nodes.nodes_pos(:,1),'YData',G_comb.Nodes.nodes_pos(:,2),'NodeColor',params.graph.vis.color_map_speedlim(G_comb))
figure,plot(G_comb,'XData',G_comb.Nodes.nodes_pos(:,1),'YData',G_comb.Nodes.nodes_pos(:,2),'NodeColor',params.graph.vis.color_map_roadtype(G_comb))


% figure,plot(G_comb,'Layout','force','NodeColor',reshape([nodes_colors{:}],3,[])')