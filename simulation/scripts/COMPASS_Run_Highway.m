close all
clc
%% 启动SUMO仿真
% 从参数服务器获取参数
global params %#ok
if exist('simCaseNumber','var')
    params = LianYG_YC_params(simCaseNumber);
else
    params = LianYG_YC_params();
end
% 求解步数
plan_steps = 0;
lastDecisionTimeGap = 0;
theScene = []; % 初始化一下最优决策场景theScene
% 加载地图数据
if ~exist('entity_dict','var')
    global entity_dict connection_dict dirArrowMap lane_to_connection_dict type_dict  %#ok
    global lane_from_connection_dict new_entity_dict proxyMat smallMap map to_connection_dict %#ok
    load(params.mat_data_name);
    
end
vehicleID = params.vehicleID;
if params.if_start_sim
    sumoCmd = [params.sumoBinary ' -c "data\test_cases\' params.sumo_file_name '"' ' --start --quit-on-end' params.seed];
    traci.start(sumoCmd);
    % 设置SUMO GUI的视角和跟踪车辆
    traci.gui.setSchema(params.viewID, params.schema);
    traci.gui.setZoom(params.viewID, params.zoomLevel);
    if isempty(params.InitTime)
        traci.simulationStep(); % 进行一步仿真
    else
        while traci.simulation.getTime()<params.InitTime
            traci.simulationStep(); % 进行一步仿真
        end
    end
    vehicleIDs = traci.vehicle.getIDList(); % 获取所有车辆ID
    % 聚焦到指定车辆
    traci.gui.trackVehicle(params.viewID, vehicleID);
end
% 创建结果输出保存文件夹
if ~exist(params.output_dir,'dir')
    mkdir(params.output_dir);
    disp(['创建仿真结果输出文件夹：' params.output_dir]);
end
%% 导入地图
% load ProcessedMap_yizhuang.mat
figureID = params.figureID; % 用来打开自驾可视化界面GUI
resultFigID = params.resultFigID; % 用于展示运行时间结果
% 添加光源
hLight = light('Position',[10 30 200],'Style','infinite');
% 设置材质属性
material dull;
% 设置照明
lighting gouraud;
%% 定义绘图信息
plotReq_targetLane = PlotReq('color',2*[0,0.05,0.08],'faceAlpha',0.55,'height',0.03,'lineWidth',0.5,'edgeColor',[1 1 1]);
plotReq_edge = PlotReq('color','k','faceAlpha',0.6,'height',0,'lineWidth',0.5,'edgeColor',[1 1 1]);
plotReq_junction = PlotReq('color',[0 0.1 0.1],'faceAlpha',0.7,'height',-0.001);
plotReq_dirArrow = PlotReq('color','w','faceAlpha',0.9,'height',0.001,'lineWidth',0.5,'edgeColor',[1 1 1]);
GoalSphere = translate(scale(extendedObjectMesh("sphere",30),[15 15 15]),[params.EndPos 25]); % 初始化标志终点的圆球
%% 构建道路场景
%场景初始化
scenario = drivingScenario; %初始化场景
scenario.SampleTime = params.sampleTime;  
%% 构建车辆信息
sensingFront = params.sensingFront; % 假如感知范围是一个圆形，那么我关注的是自车前方sensingFront为中心的一个圆形
radius = params.display_radius; % 显示半径，配合center中心偏移，显示本车前方以center为中心radius半径的圆形区域
%% 获取自车全局路径
globalRoute = traci.vehicle.getRoute(vehicleID);


%% 在场景中添加车辆
%生成初始化的周车
maxVehNum = params.maxVehNum;
sampleTime = params.sampleTime;
vehicleDummies = cell(1,maxVehNum);
vehTrajDummies = cell(1,maxVehNum+1);
initHeading_cos_sin = [1,0];
initPos = zeros(1,3);
initWayPoints = initPos(1,[1 2])+[0 0;1 1];
initSpeed = 1e-2;
initLanePosition = 0;

%根据自车信息添加车辆
load tankTruckMesh_COMPASS.mat tankTruckMesh
global trailerMesh %#ok
load trailerMesh_COMPASS.mat trailerMesh
ego = VehicleDummy('laneID','notSpecified','edgeID','notSpecified','lanePosition',initLanePosition,'speed',initSpeed,...
        'waypoints',initWayPoints,'heading_cos_sin',initHeading_cos_sin,'length',params.egoLength,...
        'pos',initPos,'vClass','trailer','vehicle',vehicle(scenario,'ClassID',1,...
        'Position',initPos,'Mesh',tankTruckMesh,'Length',params.egoLength,'Width',params.egoWidth,'Height',params.egoHight));

ego.vehicle.PlotColor = params.egoColor;
ego = updataVehicleData(ego,entity_dict,vehicleID,sampleTime);
trajectory(ego.vehicle,ego.waypoints,ego.speed);

for idx = 1:maxVehNum
    vehicleDummies{idx} = VehicleDummy('laneID','notSpecified','lanePosition',initLanePosition,'speed',initSpeed,...
        'waypoints',initWayPoints,'heading_cos_sin',initHeading_cos_sin,...
        'pos',initPos,'vehicle',vehicle(scenario,'ClassID',1,...
        'Position',initPos,'Mesh',driving.scenario.carMesh));
    vehicleDummies{idx}.vehicle.PlotColor = [1 1 0];
    trajectory(vehicleDummies{idx}.vehicle,initWayPoints,initSpeed);
end


%% 绘制GUI初始化
maxArrowNum = 5;
COMPASS_gui = figure(figureID);
[edgeList, junctionList] = getEntityInRange(proxyMat,ego.pos([1 2]),radius,ego.edgeID);
edge_handle_dict = plot3SUMOentity(entity_dict,edgeList,figureID,plotReq_edge);
junction_handle_dict = plot3SUMOentity(entity_dict,junctionList,figureID,plotReq_junction);
ground_handle = plotGroundPlane([0.4,0.5,0.55],ego.pos([1 2]),-0.1); % 绘制地面
arrowList = queryDirArrow_withinRadius(dirArrowMap,ego.pos([1 2]),radius,maxArrowNum);
arrow_handle_dict = plot3DirectionArrow(dirArrowMap,figureID,arrowList,plotReq_dirArrow);


chasePlot(scenario.Actors(1,1),'Parent', gca,...
    'meshes','On','ViewHeight',scenario.Actors(1,1).Height*2.5,...
    'ViewPitch',13,'ViewLocation',[scenario.Actors(1,1).Length*-0.85,0]); % Height*3, Length*-3.5


set(gcf,'Color',[0.4 0.6 0.65]) % 深蓝灰,更蓝
mainAxes = gca;
egoRing = VehicleRing('num_points',20,'center',ego.pos([1 2]),'figureID',figureID); % 绘制自车的光环
egoLight = VehicleSignalLight('figureID',figureID); % 画出制动和转向灯 
egoLight.refreshPosition(ego.pos,ego.heading); % 把灯的姿态调整一下
egoBrkLightState = 0;
egoTurnLightState = 0; % -1,0,1 右,灭,左
egoSpeedDisp = Dashboard_Speed('figureID',figureID,'smallMap',smallMap); 
egoSpeedDisp.refreshMap(ego.pos,ego.heading,radius*3)
egoSpeedDisp.setSpeed(ego.speed);
[routeRelation,remainDist]=getNextRoutePointInfo(entity_dict,connection_dict,globalRoute,ego.laneID,ego.lanePosition);
egoSpeedDisp.setNavigation(routeRelation,remainDist);
% 绘制转向灯
if ego.changeLane > 0 || (ego.nearJunction && (strncmpi(routeRelation,'l',1) || strncmpi(routeRelation,'t',1)))
    % 该打左转向灯了，右转向灯应该关上
    if egoTurnLightState ~= 1
        egoTurnLightState = 1;
        egoLight.setTrunLight('left');
    end
elseif ego.changeLane < 0 || (ego.nearJunction && strncmpi(routeRelation,'r',1))
    % 该打右转向灯了，左转向灯应该关上
    if egoTurnLightState ~= -1
        egoTurnLightState = -1;
        egoLight.setTrunLight('right');
    end
else % 都应该关上啦
    if egoTurnLightState ~= 0
        egoTurnLightState = 0;
        egoLight.setTrunLight('off');
    end
end
% 重新编辑主界面Axes使其成为默认Axes
set(COMPASS_gui,'CurrentAxes',mainAxes)
egoTargetLaneID_stored = ego.getTargetLaneID;
target_lane_handle = plot3SUMOentity(entity_dict,{ego.getTargetLaneID},figureID,plotReq_targetLane);

% 添加其他车辆的预测轨迹初始结果
figure(figureID),hold on
vehTrajDummies{1} = plot3(1:2,1:2,1:2,LineWidth=params.veh_traj_width,Color=[1 0 0]);
for idx = 2:maxVehNum+1
    vehTrajDummies{idx} = plot3(1:2,1:2,1:2,LineWidth=params.veh_traj_width,Color=[1 1 0]);
end
customShowExtendedMesh(GoalSphere,'Parent',mainAxes,'Color',[1 0 0]); % 绘制终点
hold off



%% 初始化对象跟踪器
oldVehicleList = [];
availlableObjQueue = Queue_Cell(); % 还没有赋值的实体
availlableObjQueue.elements = cellfun(@(x) x, num2cell(1:maxVehNum), 'UniformOutput', false);
availlableObjQueue.count = length(availlableObjQueue.elements);
objTracking_dict= dictionary(); % 对象跟踪器，用id来映射到vehicles的序号


%% 对象感知与跟踪

center = ego.pos(1,[1 2])+ego.heading_cos_sin*sensingFront;
allVehicleList = traci.vehicle.getIDList;
[vehicleList,vehiclePos] = ...
    findNearest_N_Vehicles(allVehicleList,vehicleID,center,maxVehNum,radius);

ObjectSensing_Tracking % 集成代码更新对象

setAxisRange(ego.pos([1 2]),radius+params.radius_range);% 设置坐标轴范围，缩小到感兴趣的局部区域
pause(0.01)

if params.if_record_gif
    theFrame = getframe(gcf); %获取影片帧
    [I,map]=rgb2ind(theFrame.cdata,256); %RGB图像转索引图像
    imwrite(I,map,params.gifName,'DelayTime',params.gifDelayTime,'LoopCount',Inf) %gif图像无限循环
end


% simTime = 200; % 秒
% simTime = 10; % 秒
simTime = 1;
totalStepNum = simTime/sampleTime;
runtimeList = zeros(totalStepNum,1);% 初始化仿真时间计数
% 不可达半径，2车相向全力冲刺的距离再乘上安全系数
inreachableRadius = params.timeRange4ImpssbVehID*params.maxSpeedLimit*2*params.safetyCoeff;
stepRange4ImpssbVehID = round(params.timeRange4ImpssbVehID/sampleTime); % 每过这些步更新一次不可达周车表
impsblVehList = cell(0);
step = 0; % 初始化仿真时间步
gui_step = 1; % 画面更新的步数
for iterNum = 1:totalStepNum
    % tic;%-------------------------探针---------------开始计时
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



%%  设置DynMC-SimTree求解初始化
simFigID = 3;

allDict = struct('entity_dict',new_entity_dict,'connection_from_dict',connection_dict,'connection_to_dict',to_connection_dict, ...
    'lane_from_connection_dict',lane_from_connection_dict,'lane_to_connection_dict',lane_to_connection_dict);

resolution = 100; % 100m的精度
global simRoadNetwork_dict  graph_dict %#ok
simRoadNetwork_dict = genSimRoadNetworkDict(allDict,vehicleID);
graph_dict = createGraphDict(ego);

genMainGraphManully % 手动生成全程的大地图并赋值给全局变量G_main

edgeID_dist = genEdgeID_dist(ego.edgeID,ego.lanePosition,resolution);

route = rand(2,2);
figure(figureID),hold on
compassRoute_handle = plot3(route(:,1),route(:,2),linspace(0.5,10,length(route)),'c','linewidth',params.veh_traj_width*1.5);
hold off


% 车道变换模型区分了四种变换车道的原因：
% 
% 战略性（变道以继续行驶路线）
% 合作性（为允许其他车辆变道而进行的变道）
% 提速（其他车道允许更快行驶）
% 靠右行驶的义务
% 在每个模拟步骤中，车道变换模型会计算一个内部请求，以决定变换车道还是保持在当前车道。
% 
% 如果外部车道变换指令（0x13）与内部请求存在冲突，将通过车辆车道变换模式的当前值来解决。给定的整数被解释为一个位集（bit0是最低有效位），包含以下字段：
% 
% bit1、bit0：00 = 不做策略变更；01 = 若与TraCI请求不冲突，则进行策略变更；10 = 即使要推翻TraCI请求，也要进行策略变更
% bit3、bit2：00 = 不进行协作更改；01 = 若与TraCI请求不冲突，则进行协作更改；10 = 即使覆盖TraCI请求，也要进行协作更改
% bit5、bit4：00 = 不进行速度增益更改；01 = 若与TraCI请求不冲突，则进行速度增益更改；10 = 即使要覆盖TraCI请求，也要进行速度增益更改
% bit7、bit6：00 = 不进行右车道变更；01 = 若与TraCI请求不冲突，则进行右车道变更；10 = 即使要覆盖TraCI请求，也要进行右车道变更
% bit9，bit8： 00 = 遵循TraCI请求时不考虑其他驾驶员，调整速度以完成请求 01 = 遵循TraCI请求时避免即时碰撞，调整速度以完成请求 10 = 变道时考虑其他车辆的速度/制动间隙，调整速度以完成请求 11 = 变道时考虑其他车辆的速度/制动间隙，不调整速度
% 00 = 遵循TraCI请求时不考虑其他驾驶员，调整速度以满足请求
% 01 = 遵循TraCI请求时避免即时碰撞，调整速度以完成请求
% 10 = 变道时尊重其他车辆的速度/刹车距离，调整速度以满足请求
% 11 = 变道时尊重其他车辆的速度/制动间距，不进行速度调整
% bit11、bit10：00 = 不进行子车道变更；01 = 若与TraCI请求不冲突，则进行子车道变更；10 = 即使要覆盖TraCI请求，也要进行子车道变更

traci.vehicle.setLaneChangeMode(ego.vehID, 0b011001010110); % bit11 10 ... 2 1 0  % 自己采集数据的时候的模式
% traci.vehicle.setLaneChangeMode(ego.vehID, 0b000100010010); % bit11 10 ... 2 1 0  % 我们控制的到时候的模式
% traci.vehicle.setLaneChangeMode(ego.vehID, 256); % 限制不让车辆自主换道，但是可以sublanechange

% setSpeedMode 说明
% bit0: Regard safe speed
% bit1: Regard maximum acceleration
% bit2: Regard maximum deceleration
% bit3: Regard right of way at intersections (only applies to approaching foe vehicles outside the intersection)
% bit4: Brake hard to avoid passing a red light
% bit5: Disregard right of way within intersections (only applies to foe vehicles that have entered the intersection).
% bit6: Disregard speed limit.

traci.vehicle.setSpeedMode(ego.vehID,0b0011111); % bit6 bit5 bit4 ... bit0. bit0是考虑安全速度
ctrlMode = 'COMPASS';




%% 仿真时间后处理
% figure(resultFigID)
% subplot(2,1,1)
% plot(1:step,runtimeList*1000);
% hold on
% windowSize = 100;%指定移动平均窗口大
% smoothedRuntime = movmean(runtimeList, windowSize);% 计算移动平均值
% plot(1:step,smoothedRuntime*1000,'LineWidth',1,'Color','r');
% plot([1 step],1000*sampleTime*ones(1,2),'LineWidth',1,'Color','g');
% hold off
% legend('real runtime','smoothed','realtime limit','Location','northwest')
% xlabel('step')
% ylabel('runtime [ms]')
% subplot(2,1,2)
% histogram(runtimeList*1000,50);
% xlabel('runtime [ms]')
% ylabel('step number')

