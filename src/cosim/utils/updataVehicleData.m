function vehicle = updataVehicleData(vehicle,entity_dict,vehicleID,sampleTime,headingDynTau)
    global params %#ok
    if ~strcmp(vehicle.vehID,vehicleID) % 当这个实体被赋予给了一个新的vehicleID的时候，就需要更新车辆路线
        new_vehicle_flag = true;
        vehicle.vehID = vehicleID;
        vehicle.route = traci.vehicle.getRoute(vehicleID);
    else
        new_vehicle_flag = false;
    end
    vehicle.routeIdx = traci.vehicle.getRouteIndex(vehicleID)+1; % 更新车辆的routeIndex

    % vehicleLength = traci.vehicle.getLength(vehicleID);
    
    vehicleLength = traci.vehicle.getLength(vehicleID);% 这里默认为5了，需要再改
    
    % tic
    oldLaneNo = vehicle.getLaneNo();
    laneID = traci.vehicle.getLaneID(vehicleID);
    vehicle.laneID = laneID;
    vehicle.length = vehicleLength;
    vehicleWidth = traci.vehicle.getWidth(vehicleID);
    vehicle.width = vehicleWidth;
    vClass = traci.vehicle.getVehicleClass(vehicleID);
    vType = traci.vehicle.getTypeID(vehicleID);
    vehicle.sumo_params = params.sumo_vehicle_lib(vType);
    vehicle.vehicle.PlotColor = vehicle.sumo_params.color.^params.enlightening_factor;
    vehicle.vehicle.Length = vehicle.sumo_params.length;
    vehicle.vehicle.Width = vehicle.sumo_params.width;
    if ~strcmpi(vehicle.vClass,vClass)
        if strcmpi(vClass,'private')
            vehicle.vehicle.Height = 1.4;
            vehicle.vehicle.ClassID = 1;
            vehicle.vehicle.Mesh = driving.scenario.carMesh;
        elseif strcmpi(vClass,'truck')
            vehicle.vehicle.Height = 2.7;
            vehicle.vehicle.ClassID = 2;
            vehicle.vehicle.Mesh = driving.scenario.truckMesh;
        elseif strcmpi(vClass,'trailer')
            global trailerMesh %#ok
            vehicle.vehicle.Height = 3.5;
            vehicle.vehicle.ClassID = 2;
            vehicle.vehicle.Mesh = trailerMesh;
        elseif strcmpi(vClass,'bus')
            vehicle.vehicle.Height = 3.2;
            vehicle.vehicle.ClassID = 2;
            vehicle.vehicle.Mesh = driving.scenario.truckMesh;
        else
            vehicle.vehicle.Height = 1.4;
            vehicle.vehicle.ClassID = 1;
            vehicle.vehicle.Mesh = driving.scenario.truckMesh;
        end
        vehicle.vehicle.Length = vehicleLength;
        vehicle.vehicle.Width = vehicleWidth;


    end
    vehicle.vClass = vClass;
    vehicle.vType = vType;

    newLaneNo = vehicle.getLaneNo();
    

    oldEdgeID = vehicle.edgeID;
    newEdgeID = entity_dict{laneID}.getEdgeID();
    vehicle.edgeID = newEdgeID;

    veh_pos = traci.vehicle.getPosition(vehicleID);

    oldDev = vehicle.dev;
    [~, newDev, ~, ~] = projPoint2Polyline_mex(entity_dict{laneID}.shape, veh_pos);
    vehicle.dev = newDev;

    if new_vehicle_flag
        vehicle.changeLane = 0;
    else
        if ~strcmp(oldEdgeID,newEdgeID) % 如果到了一条新的道
            vehicle.changeLane = 0;
        else
            if newLaneNo == oldLaneNo % 至少车道还没变
                devDiff = newDev - oldDev;
                if devDiff > 0 && newDev > params.lc_thred % 保证至少有一定的偏离
                    vehicle.changeLane = 1;
                elseif devDiff < 0 && newDev < -params.lc_thred
                    vehicle.changeLane = -1;
                else
                    vehicle.changeLane = 0;
                end
            elseif newLaneNo < oldLaneNo % 向右移动啦
                vehicle.changeLane = 0; % -1
            else % newLaneNo > oldLaneNo 向左移动啦
                vehicle.changeLane = 0; % 1 
            end
        end
    end 

    vehicle.targetLaneIdx = max(min(newLaneNo + vehicle.changeLane,entity_dict{newEdgeID}.laneNum-1),0);


    dist = traci.vehicle.getLanePosition(vehicleID);
    vehicle.lanePosition = dist;
    heading = (pi/2 - traci.vehicle.getAngle(vehicleID)/180*pi);
    if heading < -pi
        heading = heading + 2*pi;
    end
    if heading > pi
        heading = heading - 2*pi;
    end
    vehicle.heading = heading;
    vehicle.heading_cos_sin = [cos(heading), sin(heading)];

    new_speed = abs(traci.vehicle.getSpeed(vehicleID))+1e-2;
    vehicle.acc = traci.vehicle.getAcceleration(vehicleID);
    vehicle.speed = new_speed;
    vehicle.waypoints = [veh_pos+vehicle.heading_cos_sin*-vehicleLength*0.5;veh_pos];
    vehicle.pos=[veh_pos,0];

    if abs(vehicle.acc) < 0.6 && vehicle.speed > 10 % 一个阈值
        vehicle.isCruising = true;
    else
        vehicle.isCruising = false;
    end
    if vehicle.isCruising
        vehicle.v_des = vehicle.speed + vehicle.acc;
    else
        % 如果在交叉口内的边，其期望速度设置为下一个路径上的正常边的期望速度，否则就是当前边的期望速度
        if strncmp(':',laneID,1) 
            vehicle.v_des = entity_dict{[vehicle.route{vehicle.routeIdx} '_0']}.speed;
        else
            vehicle.v_des = entity_dict{laneID}.speed;
        end
        vehicle.isCruising = false;
 
    end

    if (entity_dict{laneID}.length- dist) < 50 % 在路口提前50m打灯
        vehicle.nearJunction = true;
    else
        vehicle.nearJunction = false;
    end





end



%% TODO:车辆的意图预测