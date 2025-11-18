new_edgeID_dist = genEdgeID_dist(ego.edgeID,ego.lanePosition,resolution);
if isKey(simRoadNetwork_dict,new_edgeID_dist)
    edgeID_dist = new_edgeID_dist;
else
    disp('当前位置没有记录新的推演地图，别担心哒，仍然使用上一个推演地图哦')
end
s = SimScenario('net',simRoadNetwork_dict{edgeID_dist});
vehKeys = objTracking_dict.keys;

egoState = convertVehState(new_entity_dict,lane_from_connection_dict, ...
           lane_to_connection_dict,s,ego);

s = s.addVehicle(Vehicle4COMPASS('route',ego.route,...
    'routeIdx',ego.routeIdx,'routeNum',length(ego.route),'edgeID',ego.edgeID,'laneID',ego.laneID),egoState);

for i = 1:length(vehKeys)
    vehKey = vehKeys{i};
    % 下面进行判断车辆是否在仿真路网内部
    vehNo = objTracking_dict(vehKey);
    if s.net.isInNet(vehicleDummies{vehNo}.edgeID)
        vehState = convertVehState(new_entity_dict,lane_from_connection_dict, ...
                   lane_to_connection_dict,s,vehicleDummies{vehNo});
 
        s = s.addVehicle(Vehicle4COMPASS('route',vehicleDummies{vehNo}.route,...
            'routeIdx',vehicleDummies{vehNo}.routeIdx,...
            'edgeID',vehicleDummies{vehNo}.edgeID,...
            'laneID',vehicleDummies{vehNo}.laneID, ...
            'routeNum',length(vehicleDummies{vehNo}.route), ...
            'v_des',vehicleDummies{vehNo}.v_des),vehState);
    end

end

s = s.initSenario();



simSceneFig = figure(simFigID);
clf(simSceneFig)
title('周围交通实时推演情况')
xlabel('地图相对位置x坐标[m]')
ylabel('地图相对位置y坐标[m]')
grid on
plotReq_edge0 = PlotReq('color','r','faceAlpha',0.2,'height',0,'lineWidth',0.5,'edgeColor',[1 0.6 0.6]);
hold on
% 绘制道路
% plotSUMOentity(new_entity_dict,{new_entity_dict{ego.edgeID}.from},simFigID);
plotSUMOentity(new_entity_dict,s.net.edgeList,simFigID);
hold on
for i = 1:length(s.net.edgeList)
    if s.net.frindgeEdgeArray(i)
        theEdgeID = s.net.edgeList{i};
        plot3SUMOentity(new_entity_dict,{theEdgeID},simFigID,plotReq_edge0);
    end
end
% 绘制车辆
hold on
veh_text_handles = cell(s.vehNum,1);
veh_dot_handles = cell(s.vehNum,1);
veh_driveLine_handles = cell(s.vehNum,1);
for i = 1:s.vehNum
    position_string = ['pos:(' num2str(round(s.vehState(i,s.var.x))) ',' num2str(round(s.vehState(i,s.var.y))) ')'];
    pos_x = s.vehState(i,s.var.x) + 1;
    pos_y = s.vehState(i,s.var.y) + 1;
    spd_string = ['spd:' num2str(round(s.vehState(i,s.var.spd),1)) 'm/s'];
    veh_dot_handles{i} = scatter(s.vehState(i,s.var.x),s.vehState(i,s.var.y),150,"filled");
    driveLine = s.vehDriveLine{i};
    if ~isempty(driveLine)
        veh_driveLine_handles{i} = plot(driveLine(:,1),driveLine(:,2),'g','LineWidth',1.5);
    end
    if s.vehState(i,s.var.opsState) == 2
        veh_text_handles{i} = text(pos_x,pos_y,['No.' num2str(i) ', opsState=2,' position_string]);
    else
        if i == 1
            veh_text_handles{i} = text(pos_x,pos_y,{['No.' num2str(i) '--ego' ],position_string,spd_string});
        else
            veh_text_handles{i} = text(pos_x,pos_y,{['No.' num2str(i) '--' ...
                escapeUnderscore(vehicleDummies{i-1}.vehID)],position_string,spd_string} );
        end
    end
end

axis equal










































