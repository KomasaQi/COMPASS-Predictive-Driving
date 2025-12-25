
%% 场景1
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

G_comb = seamSubGraphs(graph_dict('E0'),{G_comb},proxy_dist);
G_scene1 = seamSubGraphs({G_comb},graph_dict('96615334#2'),proxy_dist);



%% 场景2
G1 = graph_dict{'48963655#1'};
G2 = graph_dict{'96614676#0'};
G_comb = seamSubGraphs(graph_dict('1264142694#1-AddedOffRampEdge'),{G1 G2},proxy_dist);
G_comb = seamSubGraphs({graph_dict{'216048993'},G_comb},graph_dict('225202305#1'),proxy_dist);
G_scene2 = seamSubGraphs({G_comb},graph_dict('96614679'),proxy_dist+10);


%% 场景3
G1 = graph_dict{'96614679-AddedOffRampEdge'};
G2 = graph_dict{'1019694875'};
G3 = graph_dict{'224832136#1'};
G4 = graph_dict{'224832140'};
G5 = graph_dict{'224832138#1-AddedOnRampEdge'};
G6 = graph_dict{'224832138#1'};
G_comb = seamSubGraphs({G1},{G2,G3},proxy_dist);
G_comb = seamSubGraphs({G_comb,G4},{G5},proxy_dist);
G_scene3 = seamSubGraphs({G_comb},{G6},proxy_dist);


%% 场景4 
G1 = graph_dict{'224832138#1-AddedOffRampEdge'};
G2 = graph_dict{'225202306#1'};
G3 = graph_dict{'1066994672#0'};
G4 = graph_dict{'225202306#2-AddedOnRampEdge'};
G5 = graph_dict{'225202306#2'};
G_comb = seamSubGraphs({G1},{G2,G3},proxy_dist);
G_comb = seamSubGraphs({G_comb},{G4},proxy_dist);
G_scene4 = seamSubGraphs({G_comb},{G5},proxy_dist);

%% 场景5
G1 = graph_dict{'225202306#2-AddedOffRampEdge'};
G2 = graph_dict{'135267608'};
G3 = graph_dict{'413494440#1'};
G4 = graph_dict{'135267611'};
G5 = graph_dict{'413494440#2-AddedOnRampEdge'};
G6 = graph_dict{'413494440#2'};
G_comb = seamSubGraphs({G1},{G2,G3},proxy_dist);
G_comb = seamSubGraphs({G_comb,G4},{G5},proxy_dist);
G_scene5 = seamSubGraphs({G_comb},{G6},proxy_dist);

%% 场景6
G1 = graph_dict{'413494440#2-AddedOffRampEdge'};
G2 = graph_dict{'761727434#0'};
G3 = graph_dict{'761727432#1'};
G4 = graph_dict{'761727435#1'};
G5 = graph_dict{'761727432#2-AddedOnRampEdge'};
G6 = graph_dict{'761727432#2'};
G_comb = seamSubGraphs({G1},{G2,G3},proxy_dist);
G_comb = seamSubGraphs({G_comb,G4},{G5},proxy_dist);
G_scene6 = seamSubGraphs({G_comb},{G6},proxy_dist);

%% 场景7
G1 = graph_dict{'761727432#2-AddedOffRampEdge'};
G2 = graph_dict{'499422417'};
G3 = graph_dict{'761727441#1'};
G4 = graph_dict{'499422416'};
G5 = graph_dict{'761727441#2-AddedOnRampEdge'};
G6 = graph_dict{'761727441#2'};
G_comb = seamSubGraphs({G1},{G2,G3},proxy_dist);
G_comb = seamSubGraphs({G_comb,G4},{G5},proxy_dist);
G_scene7 = seamSubGraphs({G_comb},{G6},proxy_dist);


%% 合并场景
G_comb = seamSubGraphs({G_scene1},{G_scene2},proxy_dist);
G_comb = seamSubGraphs({G_comb},{G_scene3},proxy_dist);
G_comb = seamSubGraphs({G_comb},{G_scene4},proxy_dist);
G_comb = seamSubGraphs({G_comb},{G_scene5},proxy_dist);
G_comb = seamSubGraphs({G_comb},{G_scene6},proxy_dist);
G_comb = seamSubGraphs({G_comb},{G_scene7},proxy_dist);

ENs_main = G_comb.Edges.EndNodes;
NPs_main = G_comb.Nodes.nodes_pos;
G_comb.Edges.Distance = sqrt((NPs_main(ENs_main(:,1),1) - NPs_main(ENs_main(:,2),1)).^2 + ...
    (NPs_main(ENs_main(:,1),2) - NPs_main(ENs_main(:,2),2)).^2);

global G_main mainTree %#ok
G_main = G_comb;

% 生成kd-tree用于快速检索
mainTree = KDTreeSearcher([G_main.Nodes.nodes_pos,G_main.Nodes.road_type*params.graph.geometry.highway_height]);

%% 画图可视化
% figure,plot(G_comb,'XData',G_comb.Nodes.nodes_pos(:,1),'YData',G_comb.Nodes.nodes_pos(:,2),'NodeColor',params.graph.vis.color_map_lanefeat(G_comb))
% figure,plot(G_comb,'XData',G_comb.Nodes.nodes_pos(:,1),'YData',G_comb.Nodes.nodes_pos(:,2),'NodeColor',params.graph.vis.color_map_freeends(G_comb))
% figure,plot(G_comb,'XData',G_comb.Nodes.nodes_pos(:,1),'YData',G_comb.Nodes.nodes_pos(:,2),'NodeColor',params.graph.vis.color_map_laneno(G_comb))
% figure,plot(G_comb,'XData',G_comb.Nodes.nodes_pos(:,1),'YData',G_comb.Nodes.nodes_pos(:,2),'NodeColor',params.graph.vis.color_map_speedlim(G_comb))
% figure,plot(G_comb,'XData',G_comb.Nodes.nodes_pos(:,1),'YData',G_comb.Nodes.nodes_pos(:,2),'NodeColor',params.graph.vis.color_map_roadtype(G_comb))


% figure,plot(G_comb,'Layout','force','NodeColor',reshape([nodes_colors{:}],3,[])')

axis equal