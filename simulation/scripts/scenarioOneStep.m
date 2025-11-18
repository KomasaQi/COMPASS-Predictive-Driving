s = s.step();

for i = 1:s.vehNum
    delete(veh_text_handles{i});
    delete(veh_driveLine_handles{i});
    position_string = ['pos:(' num2str(round(s.vehState(i,s.var.x))) ',' num2str(round(s.vehState(i,s.var.y))) ')'];
    pos_x = s.vehState(i,s.var.x) + 1;
    pos_y = s.vehState(i,s.var.y) + 1;
    spd_string = ['spd:' num2str(round(s.vehState(i,s.var.spd),1)) 'm/s'];
    set(veh_dot_handles{i},"XData",pos_x-1,"YData",pos_y-1);
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




if ifOutGIF
    theFrame = getframe(gcf); %获取影片帧
    [I,map]=rgb2ind(theFrame.cdata,256);
    imwrite(I,map,gifName,'WriteMode','append','DelayTime',gifDelayTime) %添加到图像
end