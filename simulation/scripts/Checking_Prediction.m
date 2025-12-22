COMPASS_Run_Highway
cloud_db = CloudDatabase.getInstance(); 
init_time = traci.simulation.getTime;
cloud_db.setDatabaseInitTime(init_time);
cloud_db.addVehicleData(traci.simulation.getTime-init_time, objTracking_dict, vehicleDummies, ego);
for i = 1:100 
    realWorldStepOnce;
    cloud_db.addVehicleData(traci.simulation.getTime-init_time, objTracking_dict, vehicleDummies, ego);
end
last_output_dir = params.output_dir;
cloud_db.saveData([last_output_dir '\Database.mat'])
CloudDatabase.clearInstance()
clear cloud_db
cloud_db = CloudDatabase.getInstance(); 
cloud_db.loadData([last_output_dir '\Database.mat'])
COMPASS_Run_Highway
COMPASS_Checking_01
