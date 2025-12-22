classdef CloudDatabase < handle
    % CLOUDDATABASE 单例模式存储交通流仿真数据（新增单例清除功能）
    % 核心规则：
    % 1. 字典初始化：double值→dictionary(string([]), [])；cell值→dictionary(string([]), {})
    % 2. 索引规则：double值字典→()；cell值字典→{}
    % 3. 新增clearInstance方法：彻底清除单例+重置所有数据

    % 私有实例属性
    properties (Access = private)
        % 数据库开始记录的时间
        database_init_time % 开始记录数据库时存入第一个数据对应的仿真时间

        % 车辆相关字典
        vehicleDBIDMap     % dictionary: vehID(string) → double（DBID）→ ()索引
        nextVehicleDBID    % double: 下一个车辆DBID（初始1）
        vehicleStaticInfo  % dictionary: vehID(string) → cell{struct} → {}索引
        vehicleDynamicData % dictionary: vehID(string) → cell{table} → {}索引
        timeVehicleMap     % dictionary: time(double) → cell{cell} → {}索引

        % Lane/Edge ID映射字典
        laneIDMap          % dictionary: laneStr(string) → double（DBLID）→ ()索引
        nextDBLID          % double: 下一个lane DBID（初始1）
        edgeIDMap          % dictionary: edgeStr(string) → double（DBEID）→ ()索引
        nextDBEID          % double: 下一个edge DBID（初始1）
    end

    % 构造函数设为私有
    methods (Access = private)
        function obj = CloudDatabase()
            % 初始化所有字典（匹配你的规则）
            obj.vehicleDBIDMap = dictionary(string([]), []);     
            obj.nextVehicleDBID = 1;
            obj.vehicleStaticInfo = dictionary(string([]), {});  
            obj.vehicleDynamicData = dictionary(string([]), {}); 
            obj.timeVehicleMap = dictionary(string([]), {});     

            obj.laneIDMap = dictionary(string([]), []);          
            obj.nextDBLID = 1;
            obj.edgeIDMap = dictionary(string([]), []);          
            obj.nextDBEID = 1;
        end
    end

    % 核心方法（新增clearInstance静态方法）
    methods
        % ===================== 设置数据库开始的时间 ==============================
        function setDatabaseInitTime(obj,init_time)
            obj.database_init_time = init_time;
        end
        function init_time = getDatabaseInitTime(obj)
            init_time = obj.database_init_time;
        end

        % ===================== 判断数据库是否可用 ================================
        function flag = isusable(obj,start_time,duration)
            if nargin < 2 || isempty(start_time)
                start_time = 0;
            end
            if nargin < 3 || isempty(duration)
                duration = 20;
            end
            flag = true;
            if isempty(obj.getVehicleIDsAtTime(start_time)) || isempty(obj.getVehicleIDsAtTime(start_time + duration))
                flag = false;
            end
        end
        % ===================== 数据持久化：保存数据到.mat文件 =====================
        function saveData(obj, filePath)
            % 保存所有私有属性数据到指定路径（.mat文件）
            % 输入：filePath - 保存路径，如'cloud_db_data.mat'
            dataToSave = struct();
            % 存储所有需要持久化的属性
            dataToSave.vehicleDBIDMap = obj.vehicleDBIDMap;
            dataToSave.nextVehicleDBID = obj.nextVehicleDBID;
            dataToSave.vehicleStaticInfo = obj.vehicleStaticInfo;
            dataToSave.vehicleDynamicData = obj.vehicleDynamicData;
            dataToSave.timeVehicleMap = obj.timeVehicleMap;
            dataToSave.laneIDMap = obj.laneIDMap;
            dataToSave.nextDBLID = obj.nextDBLID;
            dataToSave.edgeIDMap = obj.edgeIDMap;
            dataToSave.nextDBEID = obj.nextDBEID;
            dataToSave.database_init_time = obj.database_init_time;
            % 保存到文件
            save(filePath, '-struct', 'dataToSave');
            fprintf('数据已保存到：%s\n', filePath);
        end

        % ===================== 数据持久化：从.mat文件加载数据 =====================
        function loadData(obj, filePath)
            % 从指定.mat文件加载数据并恢复到当前实例
            % 输入：filePath - 数据文件路径
            if ~exist(filePath, 'file')
                error('文件不存在：%s', filePath);
            end
            % 加载数据
            loadedData = load(filePath);
            % 恢复所有属性（严格对应保存的字段）
            obj.vehicleDBIDMap = loadedData.vehicleDBIDMap;
            obj.nextVehicleDBID = loadedData.nextVehicleDBID;
            obj.vehicleStaticInfo = loadedData.vehicleStaticInfo;
            obj.vehicleDynamicData = loadedData.vehicleDynamicData;
            obj.timeVehicleMap = loadedData.timeVehicleMap;
            obj.laneIDMap = loadedData.laneIDMap;
            obj.nextDBLID = loadedData.nextDBLID;
            obj.edgeIDMap = loadedData.edgeIDMap;
            obj.nextDBEID = loadedData.nextDBEID;
            obj.database_init_time = loadedData.database_init_time;
            fprintf('数据已从%s恢复\n', filePath);
        end


        % ===================== 内部工具方法 =====================
        function dblid = getDBLID(obj, laneStr)
            laneStr = string(laneStr);
            % dblid = NaN;
            if ~isempty(obj.laneIDMap.keys) && isKey(obj.laneIDMap, laneStr)
                dblid = obj.laneIDMap(laneStr);
            else
                dblid = obj.nextDBLID;
                obj.laneIDMap(laneStr) = dblid;
                obj.nextDBLID = obj.nextDBLID + 1;
            end
        end

        function dbeid = getDBEID(obj, edgeStr)
            edgeStr = string(edgeStr);
            % dbeid = NaN;
            if ~isempty(obj.edgeIDMap.keys) && isKey(obj.edgeIDMap, edgeStr)
                dbeid = obj.edgeIDMap(edgeStr);
            else
                dbeid = obj.nextDBEID;
                obj.edgeIDMap(edgeStr) = dbeid;
                obj.nextDBEID = obj.nextDBEID + 1;
            end
        end

        % ===================== 对外反查方法 =====================
        function laneStr = getLaneIDByDBLID(obj, dblid)
            laneStr = "";
            if ~isempty(obj.laneIDMap.keys)
                allLaneStr = obj.laneIDMap.keys;
                allDBLID = values(obj.laneIDMap);
                idx = find(allDBLID == dblid, 1);
                if ~isempty(idx)
                    laneStr = allLaneStr(idx);
                end
            end
        end

        function edgeStr = getEdgeIDByDBEID(obj, dbeid)
            edgeStr = "";
            if ~isempty(obj.edgeIDMap.keys)
                allEdgeStr = obj.edgeIDMap.keys;
                allDBEID = values(obj.edgeIDMap);
                idx = find(allDBEID == dbeid, 1);
                if ~isempty(idx)
                    edgeStr = allEdgeStr(idx);
                end
            end
        end

        % ===================== 核心存储方法 =====================
        function addVehicleData(obj, time, varargin)
            objTracking_dict = [];
            vehicleDummies = [];
            ego = [];
            if nargin >= 3
                objTracking_dict = varargin{1};
            end
            if nargin >= 4
                vehicleDummies = varargin{2};
            end
            if nargin >= 5
                ego = varargin{3};
            end

            currentVehicles = dictionary(string([]), {});
            
            if ~isempty(objTracking_dict) && ~isempty(vehicleDummies)
                vehIDs = objTracking_dict.keys;
                for i = 1:length(vehIDs)
                    vehID = vehIDs{i};
                    dummyIdx = objTracking_dict(vehID);
                    if dummyIdx <= length(vehicleDummies)
                        currentVehicles{vehID} = vehicleDummies{dummyIdx};
                    end
                end
            end
            
            if ~isempty(ego)
                egoID = ego.vehID;
                currentVehicles{egoID} = ego;
            end

            if ~isempty(currentVehicles.keys)
                obj.timeVehicleMap{time} = {currentVehicles.keys};
            end

            vehIDs = currentVehicles.keys;
            for i = 1:length(vehIDs)
                vehID = vehIDs{i};
                dummy = currentVehicles{vehID};

                isNewVeh = true;
                if ~isempty(obj.vehicleDBIDMap.keys)
                    isNewVeh = ~isKey(obj.vehicleDBIDMap, vehID);
                end
                if isNewVeh
                    obj.vehicleDBIDMap(vehID) = obj.nextVehicleDBID;
                    obj.nextVehicleDBID = obj.nextVehicleDBID + 1;

                    staticInfo = struct(...
                        'vClass', dummy.vClass, ...
                        'vType', dummy.vType, ...
                        'route', dummy.route, ...
                        'length', dummy.length, ...
                        'width', dummy.width, ...
                        'dbID', obj.vehicleDBIDMap(vehID));
                    obj.vehicleStaticInfo{vehID} = staticInfo;
                end

                dynamicData = struct(...
                    'time', time, ...
                    'acc', dummy.acc, ...
                    'speed', dummy.speed, ...
                    'heading', dummy.heading, ...
                    'heading_cos_sin', dummy.heading_cos_sin, ...
                    'pos', dummy.pos, ...
                    'DBLID', obj.getDBLID(dummy.laneID), ...
                    'DBEID', obj.getDBEID(dummy.edgeID), ...
                    'lanePosition', dummy.lanePosition, ...
                    'routeIdx', dummy.routeIdx, ...
                    'dev', dummy.dev);

                isNewDynamic = true;
                if ~isempty(obj.vehicleDynamicData.keys)
                    isNewDynamic = ~isKey(obj.vehicleDynamicData, vehID);
                end
                if isNewDynamic
                    obj.vehicleDynamicData{vehID} = struct2table(dynamicData);
                else
                    tbl = obj.vehicleDynamicData{vehID};
                    tbl = [tbl; struct2table(dynamicData)]; %#ok<AGROW>
                    obj.vehicleDynamicData{vehID} = tbl;
                end
            end
        end

        % ===================== 数据查询方法 =====================
        function allHistory = getVehicleAllHistory(obj, vehID)
            allHistory = table();
            if ~isempty(obj.vehicleDynamicData.keys) && isKey(obj.vehicleDynamicData, vehID)
                tbl = obj.vehicleDynamicData{vehID};
                tbl.laneID = arrayfun(@(x)obj.getLaneIDByDBLID(x), tbl.DBLID, 'UniformOutput', false);
                tbl.edgeID = arrayfun(@(x)obj.getEdgeIDByDBEID(x), tbl.DBEID, 'UniformOutput', false);
                colOrder = {'time','acc','speed','heading','heading_cos_sin','pos',...
                    'laneID','edgeID','lanePosition','routeIdx','dev'};
                allHistory = tbl(:, colOrder);
            end
        end

        function data = getVehicleDataAtTime(obj, vehID, time)
            data = struct();
            if ~isempty(obj.vehicleDynamicData.keys) && isKey(obj.vehicleDynamicData, vehID)
                tbl = obj.vehicleDynamicData{vehID};
                timeIdx = tbl.time == time;
                if any(timeIdx)
                    tempData = table2struct(tbl(timeIdx, :), 'ToScalar', true);
                    data.time = tempData.time;
                    data.acc = tempData.acc;
                    data.speed = tempData.speed;
                    data.heading = tempData.heading;
                    data.heading_cos_sin = tempData.heading_cos_sin;
                    data.pos = tempData.pos;
                    data.laneID = obj.getLaneIDByDBLID(tempData.DBLID);
                    data.edgeID = obj.getEdgeIDByDBEID(tempData.DBEID);
                    data.lanePosition = tempData.lanePosition;
                    data.routeIdx = tempData.routeIdx;
                    data.dev = tempData.dev;
                end
            end
        end

        function vehIDs = getVehicleIDsAtTime(obj, time)
            vehIDs = {};
            if ~isempty(obj.timeVehicleMap.keys) && isKey(obj.timeVehicleMap, time)
                vehIDs = obj.timeVehicleMap{time}{1};
            end
        end

        function allData = getAllVehicleDataAtTime(obj, time)
            allData = struct([]);
            vehIDs = obj.getVehicleIDsAtTime(time);
            if isempty(vehIDs)
                return;
            end
            allData = struct('vehID', {}, 'data', {});
            for i = 1:length(vehIDs)
                vehID = vehIDs{i};
                data = obj.getVehicleDataAtTime(vehID, time);
                if ~isempty(data)
                    allData(i).vehID = vehID;
                    allData(i).data = data;
                end
            end
        end

        % ===================== 辅助查询方法 =====================
        function dbID = getVehicleDBID(obj, vehID)
            dbID = NaN;
            if ~isempty(obj.vehicleDBIDMap.keys) && isKey(obj.vehicleDBIDMap, vehID)
                dbID = obj.vehicleDBIDMap(vehID);
            end
        end

        function staticInfo = getVehicleStaticInfo(obj, vehID)
            staticInfo = struct();
            if ~isempty(obj.vehicleStaticInfo.keys) && isKey(obj.vehicleStaticInfo, vehID)
                staticInfo = obj.vehicleStaticInfo{vehID};
            end
        end

        % ===================== 实例内数据重置方法（私有） =====================
        function resetData(obj)
            % 重置所有字典和计数器，清空实例内数据
            obj.vehicleDBIDMap = dictionary(string([]), []);     
            obj.nextVehicleDBID = 1;
            obj.vehicleStaticInfo = dictionary(string([]), {});  
            obj.vehicleDynamicData = dictionary(string([]), {}); 
            obj.timeVehicleMap = dictionary(string([]), {});     

            obj.laneIDMap = dictionary(string([]), []);          
            obj.nextDBLID = 1;
            obj.edgeIDMap = dictionary(string([]), []);          
            obj.nextDBEID = 1;
        end
    end

    % 静态方法：单例实现+清除单例
    methods (Static)
        function obj = getInstance()
            persistent localInstance
            if isempty(localInstance)
                localInstance = CloudDatabase();
            end
            obj = localInstance;
        end

        function clearInstance()
            % 对外暴露的清除单例方法：清空persistent变量+重置数据
            persistent localInstance
            if ~isempty(localInstance)
                localInstance.resetData(); % 先重置实例内所有数据
                localInstance = []; % 清空persistent变量
            end
            % 清除工作区可能存在的db变量（可选，增强清空效果）
            if exist('db', 'var')
                clear db;
            end
        end
    end
end