params = LianYG_YG_params(); 
insert_nodes_pos = seamSubGraphs({G1},{G2});
figure(9),
scatter(insert_nodes_pos(:,1),insert_nodes_pos(:,2),'fill')
axis equal
