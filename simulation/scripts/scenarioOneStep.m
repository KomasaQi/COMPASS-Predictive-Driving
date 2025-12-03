%#######################COMPASS交互式推演模块可视化检查#########################

%*********************************步进一步*************************************
% 进行一步场景仿真
s = s.step();

for i = 1:s.vehNum
    % 设置车辆轨迹线结果
    driveLine = s.vehDriveLine{i};
    if ~isempty(driveLine)
        set(veh_driveLine_handles{i},'XData',driveLine(:,1),'YData',driveLine(:,2));
    end

end

for i = 1:s.vehNum
    % 删除上一帧的可视化图形
    delete(veh_text_handles{i});
    

    % 从仿真结果提取状态信息
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
    set(veh_dot_handles{i},"XData",pos_x+[0,-cos(heading)*s.vehicles{i}.L],"YData",pos_y+[0,-sin(heading)*s.vehicles{i}.L]);

    % 设置相关参数显示
    if s.vehState(i,s.var.opsState) == 2
        veh_text_handles{i} = text(pos_x + params.scenario_gui.text_x_dev, ...
            pos_y + params.scenario_gui.text_y_dev,['No.' num2str(i) ', opsState=2,' position_string],'Color',(s.vehicles{i}.color*0.9+0.1).^0.1);
    else
        if i == 1
            veh_text_handles{i} = text(pos_x + params.scenario_gui.text_x_dev, ...
                pos_y + params.scenario_gui.text_y_dev,{['No.' num2str(i) '--ego' ], ...
                spd_string,position_string},"FontSize",params.scenario_gui.font_size,"FontWeight","bold",'Color',(s.vehicles{i}.color*0.9+0.1).^0.1);
        else
            veh_text_handles{i} = text(pos_x + params.scenario_gui.text_x_dev, ...
                pos_y + params.scenario_gui.text_y_dev,{['No.' num2str(i) '--' ...
                escapeUnderscore(vehicleDummies{i-1}.vehID)], ...
                spd_string,position_string} ,"FontSize",params.scenario_gui.font_size,'Color',(s.vehicles{i}.color*0.9+0.1).^0.1);
        end
    end
end

% GIF动图结果记录
if params.if_record_gif
    theFrame = getframe(gcf); %获取影片帧
    [I,map]=rgb2ind(theFrame.cdata,256);
    imwrite(I,map,params.gifName,'WriteMode','append','DelayTime',params.gifDelayTime) %添加到图像
end