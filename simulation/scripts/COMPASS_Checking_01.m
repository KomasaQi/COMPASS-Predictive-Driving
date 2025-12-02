%#######################COMPASS交互式推演模块可视化检查#########################
%% 初始化推演场景
% 获取当前位置推演用的地图
new_edgeID_dist = genEdgeID_dist(ego.edgeID,ego.lanePosition,resolution);
if isKey(simRoadNetwork_dict,new_edgeID_dist)
    edgeID_dist = new_edgeID_dist;
else
    disp('当前位置没有记录新的推演地图，别担心哒，仍然使用上一个推演地图哦')
end

% 生成推演场景
s = SimScenario('net',simRoadNetwork_dict{edgeID_dist});

% 获取当前对象跟踪器映射
vehKeys = objTracking_dict.keys;

% 添加自车和他车到场景
egoState = convertVehState(new_entity_dict,lane_from_connection_dict, ...
           lane_to_connection_dict,s,ego);

s = s.addVehicle(Vehicle4COMPASS('route',ego.route,...
    'routeIdx',ego.routeIdx,'routeNum',length(ego.route),'edgeID',ego.edgeID,'laneID',ego.laneID,...
                'L',ego.length,...
            'W',ego.width),egoState);

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
            'v_des',vehicleDummies{vehNo}.v_des,...
            'L',vehicleDummies{vehNo}.length,...
            'W',vehicleDummies{vehNo}.width),vehState);
    end

end

% 推演场景初始化
s = s.initSenario();


%% 可视化界面绘制
% 获取仿真检查界面的ID
simSceneFig = figure(simFigID);
clf(simSceneFig)
title('周围交通实时推演情况')
xlabel('地图相对位置x坐标[m]')
ylabel('地图相对位置y坐标[m]')
grid on
plotReq_edge0 = PlotReq('color','r','faceAlpha',0.2,'height',0,'lineWidth',0.5,'edgeColor',[1 0.6 0.6]);
hold on
% 绘制道路
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
    % 获取当前车辆状态
    pos_x = s.vehState(i,s.var.x);
    pos_y = s.vehState(i,s.var.y);
    heading = s.vehState(i,s.var.heading);
    
    % 生成提示参数
    if params.scenario_gui.show_pos
        position_string = ['pos:(' num2str(round(pos_x)) ',' num2str(round(pos_y)) ')'];
    else
        position_string = [];
    end
    if params.scenario_gui.show_spd
        spd_string = ['spd:' num2str(round(s.vehState(i,s.var.spd),1)) 'm/s'];
    else
        spd_string = [];
    end

    % 设置车辆轨迹线结果
    driveLine = s.vehDriveLine{i};
    if ~isempty(driveLine)
        veh_driveLine_handles{i} = plot(driveLine(:,1),driveLine(:,2),'g','LineWidth',1.5);
    end

    % 设置车头车尾位置
    if i == 1
        veh_dot_handles{i} = plot(pos_x+[0,-cos(heading)*s.vehicles{i}.L],...
            pos_y+[0,-sin(heading)*s.vehicles{i}.L], ...
            "Color",[0.8941 0.6275 0.4471],"LineWidth",5);
    else
        veh_dot_handles{i} = plot(s.vehState(i,s.var.x)+[0,-cos(s.vehState(i,s.var.heading))*s.vehicles{i}.L],...
            s.vehState(i,s.var.y)+[0,-sin(s.vehState(i,s.var.heading))*s.vehicles{i}.L], ...
            "LineWidth",5);
    end
    
    % 设置相关参数显示
    if s.vehState(i,s.var.opsState) == 2
        veh_text_handles{i} = text(pos_x + params.scenario_gui.text_x_dev, ...
                pos_y + params.scenario_gui.text_y_dev,['No.' num2str(i) ', opsState=2,' position_string]);
    else
        if i == 1
            veh_text_handles{i} = text(pos_x + params.scenario_gui.text_x_dev, ...
                pos_y + params.scenario_gui.text_y_dev,{['No.' num2str(i) '--ego' ], ...
                spd_string,position_string},"FontSize",params.scenario_gui.font_size,"FontWeight","bold");
        else
            veh_text_handles{i} = text(pos_x + params.scenario_gui.text_x_dev, ...
                pos_y + params.scenario_gui.text_y_dev,{['No.' num2str(i) '--' ...
                escapeUnderscore(vehicleDummies{i-1}.vehID)], ...
                spd_string,position_string},"FontSize",params.scenario_gui.font_size);
        end
    end
end

axis equal










































