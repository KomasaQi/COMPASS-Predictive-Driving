

COMPASS_Run_Highway
% cloud_db = CloudDatabase.getInstance(); 
init_time = traci.simulation.getTime;
cloud_db = CloudDatabase(params,init_time);
cloud_db.addVehicleData(traci.simulation.getTime-init_time, objTracking_dict, vehicleDummies, ego);
for i = 1:1000
    realWorldStepOnce;
    cloud_db.addVehicleData(traci.simulation.getTime-init_time, objTracking_dict, vehicleDummies, ego);
    if norm(ego.pos([1 2]) - params.EndPos) < params.simulation.endThresholdRange
        last_output_dir = params.output_dir;
        save([last_output_dir '\Database.mat'],'cloud_db');
        traci.close();
        break;
    end
end


% 
% 
% load([last_output_dir '\Database.mat'])
% COMPASS_Run_Highway
% % COMPASS_Checking_01
