

function height = calcVehicleHeight(veh_dummy)
    % 提取基本信息
    % vehID = veh_dummy.vehID;
    laneID = veh_dummy.laneID;
    edgeID = veh_dummy.edgeID;
    global entity_dict params connection_dict %#ok
    % 创建道路类型特征
    
    roadTypeID = entity_dict{edgeID}.type;
    % roadType = type_dict{roadTypeID};
    distance = xy2dist(entity_dict{laneID}.shape); 

    if strcmpi(roadTypeID,'highway.motorway')
        height = params.graph.road_type_feat.highway_motorway;
    elseif strncmpi(edgeID,':',1)
        height = params.graph.road_type_feat.highway_motorway;

    elseif strcmpi(roadTypeID,'highway.motorway_link')
        % 判断link是否是连接主路的
        link_mainRoad = false;
        if isKey(connection_dict,edgeID)
            connections = connection_dict{edgeID};
            for i = 1:connections.connection_num
                conn = connections.connections{i};
                if strcmpi(entity_dict{conn.to}.type,'highway.motorway')
                    
                    link_mainRoad = true;
                    break
                end
            end
        end
        if link_mainRoad
            height = interp1(distance,distance/distance(end),veh_dummy.lanePosition);
        else
            height = interp1(distance,1-distance/distance(end),veh_dummy.lanePosition);
        end
        
    else
        height = params.graph.road_type_feat.others;
    end

    height = params.graph.geometry.highway_height * height;
    
end