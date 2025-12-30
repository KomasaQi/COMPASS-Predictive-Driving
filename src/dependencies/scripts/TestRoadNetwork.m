net = RoadNetwork();
scale_factor = 50;
nodes = [1,5;
         6,6;
         2,10;
         -5,8;
         -4,4;
         -4,0;
         1,1;
         5,2;
         15,15]*scale_factor;

for i = 1:size(nodes,1)
    net = net.add_node(nodes(i,:));
end

middle_cv{1,2}=[2,5.2;3.5,5.2]*scale_factor;
middle_cv{1,3}=[0.5 7;1,8.5]*scale_factor;
middle_cv{2,3}=[5 7;8,9;5,11]*scale_factor;
middle_cv{3,4}=[-1,9;-3,9]*scale_factor;
middle_cv{4,5}=[-4.5,6]*scale_factor;
middle_cv{1,5}=[-2,4.2]*scale_factor;
middle_cv{1,7}=[2,3]*scale_factor;
middle_cv{7,8}=[1,0;3,2]*scale_factor;
middle_cv{8,2}=[5,3]*scale_factor;
middle_cv{6,7}=[-3,0]*scale_factor;
middle_cv{5,6}=[-3,3;-4,1]*scale_factor;
middle_cv{2,9}=[8,6;10,8;15,6]*scale_factor;
% middle_cv{2,1}=
laneNum = 3;
laneWidth = 3.5;


figure
for i =1:size(nodes,1)
    text(nodes(i,1),nodes(i,2),num2str(i));
end
for node1_num = 1:size(middle_cv,1)
    for node2_num = 1:size(middle_cv,2)
        if ~isempty(middle_cv{node1_num,node2_num})
            [Road1,Road2] = net.create2WayRoad(node1_num,node2_num,middle_cv{node1_num,node2_num},[laneNum,laneNum],laneWidth);
            net = net.add2WayRoad(node1_num,node2_num,Road1,Road2);
            Road1.show(-1)
            Road2.show(-1)
        end
    end
end
net.proxyMat



