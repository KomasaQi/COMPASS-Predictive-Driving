% 生成推演场景
new_edgeID_dist = '135267593[@0]';
if isKey(simRoadNetwork_dict,new_edgeID_dist)
    edgeID_dist = new_edgeID_dist;
else
    disp('当前位置没有记录新的推演地图，别担心哒，仍然使用上一个推演地图哦')
end
s = SimScenario('net',simRoadNetwork_dict{edgeID_dist});
plotReq_edge0 = PlotReq('color','r','faceAlpha',0.9,'height',0,'lineWidth',0.5,'edgeColor',[1 0.9 0.9]);
figure
hold on
% 绘制道路
plotSUMOentity(new_entity_dict,s.net.edgeList,simFigID,0.9,[1 1 1]);
hold on
for i = 1:length(s.net.edgeList)
    if s.net.frindgeEdgeArray(i)
        theEdgeID = s.net.edgeList{i};
        plot3SUMOentity(new_entity_dict,{theEdgeID},simFigID,plotReq_edge0);
    end
end