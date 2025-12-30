for iters = 1:1 %iteration_tot_num
    tic
    % 进行换道决策
    vehicles = GlobalMobile(vehicles,jump_list,net);
    % 打印轨迹规划结果
    for i = 1:veh_num
        disp(['第' num2str(i) '辆车：' ])
        disp(num2str(vehicles{i}.planner.surr_veh_ids))
        disp(num2str(vehicles{i}.planner.surr_veh_inteqldist))
    end

    for i = 1:veh_num
        disp(['第' num2str(i) '辆车：'...
            num2str(vehicles{i}.planner.current_lane_id) ' -> ' ...
            num2str(vehicles{i}.planner.target_lane_id)])
    end
    % 进行轨迹规划并步进
    for i = 1:veh_num 
        datalogs{i} = datalogs{i}.logData(vehicles{i}); % 记录车辆数据
        front_veh_id = vehicles{i}.planner.surr_veh_ids(1,2);
        if front_veh_id==0
            vehicles{i} = vehicles{i}.step([]);
        else
            vehicles{i} = vehicles{i}.step(vehicles{front_veh_id});
        end
        
        if ~isempty(veh_dot{i})
            for part_num = 1:length(veh_dot{i})
                delete(veh_dot{i}{part_num})
            end
        end
        delete(veh_text{i})
        delete(veh_path{i})
        hold on % 打印一下所有车的编号
        veh_path{i} = plot(vehicles{i}.refpath(:,1),vehicles{i}.refpath(:,2),'k',LineWidth=1);
        veh_dot{i} = vehicles{i}.show(colorMap{i});
        veh_text{i} = text(vehicles{i}.pos(1),vehicles{i}.pos(2),num2str(i));
        hold off

    end
    toc
    pause(0.0001)
    disp(num2str(iters))
end