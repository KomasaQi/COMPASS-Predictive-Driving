%#######################COMPASS交互式推演模块可视化检查#########################
%% 初始化推演场景
initCurrentScenario

% 判断是否需要展示云端数据库回放对比
compare_database = false;
if exist('cloud_db') && cloud_db.isusable() %#ok
    compare_database = true;
end

%% 可视化界面绘制
% 获取仿真检查界面的ID
simSceneFig = figure(simFigID);
clf(simSceneFig)
title('周围交通实时推演情况','Color','w',"FontWeight","bold")
xlabel('地图相对位置x坐标[m]')
ylabel('地图相对位置y坐标[m]')
grid on
plotReq_edge0 = PlotReq('color','r','faceAlpha',0.9,'height',0,'lineWidth',0.5,'edgeColor',[1 0.9 0.9]);
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
% 绘制车辆
hold on
veh_text_handles = cell(s.vehNum,1);
veh_dot_handles = cell(s.vehNum,1);
veh_driveLine_handles = cell(s.vehNum,1);
if compare_database
    playback_veh_handles = cell(s.vehNum,1);
    sim_start_time = traci.simulation.getTime;
end

for i = 1:s.vehNum
    % 设置车辆轨迹线结果
    driveLine = s.vehDriveLine{i};
    if ~isempty(driveLine)
        veh_driveLine_handles{i} = plot(driveLine(:,1),driveLine(:,2),'LineWidth',1.5,'Color',s.vehicles{i}.color.^0.2);
    end
end
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


    % 设置车头车尾位置
    if compare_database
        theVehID = s.vehicles{i}.id;
        theVehData = cloud_db.getVehicleDataAtTime(theVehID,sim_start_time - cloud_db.getDatabaseInitTime);
        if ~isempty(fieldnames(theVehData))
            playback_veh_handles{i} = plot(theVehData.pos(1)+[0,-cos(theVehData.heading)*s.vehicles{i}.L],...
            theVehData.pos(2)+[0,-sin(theVehData.heading)*s.vehicles{i}.L], ...
            "LineWidth",5,'Color',[(s.vehicles{i}.color*0.8+(1-0.8)*[1 0 0]),0.5]);
        end
    end
    veh_dot_handles{i} = plot(s.vehState(i,s.var.x)+[0,-cos(s.vehState(i,s.var.heading))*s.vehicles{i}.L],...
        s.vehState(i,s.var.y)+[0,-sin(s.vehState(i,s.var.heading))*s.vehicles{i}.L], ...
        "LineWidth",5,'Color',s.vehicles{i}.color);

    
    % 设置相关参数显示
    if s.vehState(i,s.var.opsState) == 2
        veh_text_handles{i} = text(pos_x + params.scenario_gui.text_x_dev, ...
                pos_y + params.scenario_gui.text_y_dev,['No.' num2str(i) ', opsState=2,' position_string],'color',(s.vehicles{i}.color*0.9+0.1).^0.1);
    else
        if i == 1
            veh_text_handles{i} = text(pos_x + params.scenario_gui.text_x_dev, ...
                pos_y + params.scenario_gui.text_y_dev,{['No.' num2str(i) '--ego' ], ...
                spd_string,position_string},"FontSize",params.scenario_gui.font_size,"FontWeight","bold",'color',(s.vehicles{i}.color*0.9+0.1).^0.1);
        else
            veh_text_handles{i} = text(pos_x + params.scenario_gui.text_x_dev, ...
                pos_y + params.scenario_gui.text_y_dev,{['No.' num2str(i) '--' ...
                escapeUnderscore(vehicleDummies{i-1}.vehID)], ...
                spd_string,position_string},"FontSize",params.scenario_gui.font_size,'color',(s.vehicles{i}.color*0.9+0.1).^0.1);
        end
    end
end

axis equal
set(gcf,'color',[91,114,125]/255)
axis off









































