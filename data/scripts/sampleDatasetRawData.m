%% 采样各种场景，为数据集增加数据量
sampleTrajectoryNumber = 1000;
simCaseNumber = 1;
for sampleNumber = 1:sampleTrajectoryNumber
    COMPASS_Run_Highway
    init_time = traci.simulation.getTime;
    cloud_db = CloudDatabase(params,G_main,init_time);
    cloud_db.addVehicleData(traci.simulation.getTime-init_time, objTracking_dict, vehicleDummies, ego);
    tic % 计时一次采样用时
    for i = 1:1000
        realWorldStepOnce;
        cloud_db.addVehicleData(traci.simulation.getTime-init_time, objTracking_dict, vehicleDummies, ego);
        if norm(ego.pos([1 2]) - params.EndPos) < params.simulation.endThresholdRange
            output_name = params.output_dir;
            save([params.sample.savedir output_name(8:end) '.mat'],'cloud_db');
            traci.close();
            break;
        end
    end
    sample_time_cost = toc; % 输出一次采样用时
    fprintf('采样第 %d 个样本完成！花费时间: %f s, 包含: %d 个时间样本\n', sampleNumber, sample_time_cost, cloud_db.len);
end