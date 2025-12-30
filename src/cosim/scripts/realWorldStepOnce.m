for i = 1:params.update_interval
    % 进行一步仿真，需要先运行get_DynMC_SimTree_route进行规划才行哦
    % spdDesCmdDeviationStep = spdDesCmdDeviationStep + 1;
    lastDecisionTimeGap = lastDecisionTimeGap + params.sampleTime;
    iterNum = iterNum + 1;
    % tic;%-------------------------探针---------------开始计时
    % thredSpd = theScene.getEgoDesSpd+5;
    % if strcmp(ctrlMode,'COMPASS')
    %     if ego.speed < thredSpd
    %         spdDesCmd = spdDesCmds(spdDesCmdDeviationStep);
    %     else
    %         spdDesCmd = thredSpd;
    %     end
    %     traci.vehicle.setSpeed(ego.vehID,spdDesCmd);
    % end
    traci.simulation.step() % 进行一步仿真
    allVehicleList = traci.vehicle.getIDList;
    
    if ~mod(iterNum,stepRange4ImpssbVehID)
        impsblVehList = getImpsblVehList(allVehicleList,ego.pos([1 2]),inreachableRadius);
    end
    
    if ~max(ismember(allVehicleList,vehicleID)) % 如果被控本车到终点了就结束啦
        traci.close(); % 结束仿真
        % runtimeList(step+1:end) = [];
        break
    end
    
    step = step + 1; % 进行仿真步计数
    
    if ~mod(iterNum,params.update_interval)
        UpdateCloudData_RefreshCOMPASS_GUI
    end % 对应if ~mod(iterNum,params.update_interval)

end