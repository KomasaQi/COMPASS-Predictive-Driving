%%%%%%%%%%%%%%%%%%%集成代码：云端目标跟踪#################
addVehicleList = setdiff(vehicleList,oldVehicleList); % 新加入的，需要维护出队入队，更新位置
outVehicleList = setdiff(oldVehicleList,vehicleList); % 退出的，需要更新位置到默认点并更新关系
existingVehicleList = intersect(vehicleList,oldVehicleList); % 之前就有现在还有的，需要更新位置


%%%%%% 退出的，需要更新位置到默认点并更新关系
if ~isempty(outVehicleList)
    for j = 1:length(outVehicleList)
        deleteID = outVehicleList{j};
        entityIdx = objTracking_dict(deleteID);
        availlableObjQueue = availlableObjQueue.enqueue(entityIdx);% 把可用实体还回去
        objTracking_dict(deleteID) = [];% 删除掉最早的车辆与实体的对应关系
    
        trajectory(vehicleDummies{entityIdx}.vehicle,initWayPoints,initSpeed);
    end
end

%%%%%% 新加入的，需要维护出队入队，更新位置
if ~isempty(addVehicleList)
    for j = 1:length(addVehicleList)
 
        addVehID = addVehicleList{j};
        [availlableObjQueue,entityIdx] = availlableObjQueue.dequeue();% 分配一个可用实体出去
        objTracking_dict(addVehID) = entityIdx;% 建立新加入车辆与显示实体的对应关系

        vehicleDummies{entityIdx} = ...
            updataVehicleData(vehicleDummies{entityIdx},entity_dict,addVehID,sampleTime);
        trajectory(vehicleDummies{entityIdx}.vehicle,...
            vehicleDummies{entityIdx}.waypoints,vehicleDummies{entityIdx}.speed);
    end
end


%%%%%% 之前就有现在还有的，需要更新位置
if ~isempty(existingVehicleList) 
    for j = 1:length(existingVehicleList)
        existID = existingVehicleList{j};
        entityIdx = objTracking_dict(existID);
        vehicleDummies{entityIdx} = ...
            updataVehicleData(vehicleDummies{entityIdx},entity_dict,existID,sampleTime);
        trajectory(vehicleDummies{entityIdx}.vehicle,...
            vehicleDummies{entityIdx}.waypoints,vehicleDummies{entityIdx}.speed); 
    end
end