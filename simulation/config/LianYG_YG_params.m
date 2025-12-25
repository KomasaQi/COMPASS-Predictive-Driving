%连云港-盐城仿真参数配置
function params = LianYG_YG_params()
    %% 仿真案例设置
    % 案例基本信息
    params.case_number = 1;      % 仿真案例代号（1~28）
    params.sampleTime = 0.1;     % DrivingScenario采样时间与SUMO同默认0.1s
    params.if_start_sim  = true; % 是否进行仿真 
    params.mat_data_name = 'ProcessedMap_lianyg_yanc_w_type.mat'; % 路网预处理文件名称
    params.vehicleID = 't_0';

    % 案例相关参数读取
    [params.sumo_file_name, ... % sumo仿真文件名称
     params.rou_file_name, ...  % sumo路线文件名称
     params.DepartTime, ...     % 自车发车标称时间
     params.InitTime, ...       % COMPASS仿真开始时间
     params.EndPos, ...        % 案例结束位置
     params.S_main, ...         % 主路线交通流量 辆/h
     params.S_exit, ...         % 下匝道交通流量 辆/h
     params.S_merge, ...        % 汇入车交通流量 辆/h
     params.Avg_Stream, ...     % 平均交通流量（和）辆/h
     params.If_Finish, ...      % 案例是否已经搭建完成
     params.Case_Name...        % 案例基础名称
    ] = get_testCaseName_Highway(params.case_number);
    if ~params.If_Finish && params.if_start_sim
       error('仿真场景案例未设置，无法进行仿真哒，请检查一下是否做了这个场景的sumo文件并配置了xlsx表格！')
    end
    params.sumo_vehicle_lib = readSumoRouFile_getSumoVehLib(['./data/test_cases/' params.rou_file_name]);
    params.simulation.endThresholdRange = 30; % 接近案例结束位置这个距离就算作仿真结束
    
    %% 仿真界面设置
    % SUMO界面设置
    params.sumoBinary = 'sumo-gui'; % 或者使用'sumo'进行无GUI仿真 
    params.viewID = 'View #0'; % 默认视角ID
    params.schema = 'real world';  % 设置SUMO GUI的显式模式为'real world'
    params.zoomLevel = 50000; % 根据需要调整放大倍数
    
    % COMPASS界面设置
    params.figureID = 1;               % 用来打开自驾可视化界面GUI
    params.resultFigID = 2;            % 用于展示运行时间结果
    params.tau_heading = 0.1;          % 定义用于画面显示的虚拟动力学
    params.sensingFront = 5;           % 假如感知范围是一个圆形，那么我关注的是自车前方sensingFront为中心的一个圆形
    params.display_radius = 200;       % 显示半径，配合center中心偏移，显示本车前方以center为中心radius半径的圆形区域
    params.enlightening_factor = 0.4;  % GUI界面车辆颜色提亮系数（加上阴影以后比sumo暗淡了，需要提亮才能看上去和sumo一样）
    params.radius_range = 250;         % 查找周车的范围再+的范围用于可视化
    params.update_interval = 5;        % 云端隔多少个时间周期步能获得一次全局信息（单位0.1s）
    params.arrow_refreshStepInterval = 5;         % 刷新箭头的步数间隔
    params.edge_junction_refreshStepInterval = 7; % 刷新路面的步数间隔
    params.ring_refreshStepInterval = 1;          % 车辆光环刷新的步数间隔
    params.timeRange4ImpssbVehID = 5;             % 这些时间间隔之后会更新一次不可能到达的周车状态
    params.maxSpeedLimit = 120/3.6;               % 最高时速限制
    params.safetyCoeff = 1.5;                     % 不可达距离安全系数
    params.veh_traj_alpha = 0.3;                  % 周车轨迹的不透明度
    params.veh_traj_width = 5;                    % 周车轨迹粗细

    % 推演检查界面设置
    params.scenario_gui.show_pos = false; % 推演检查界面是否显示车辆位置
    params.scenario_gui.show_spd = true;  % 推演检查界面是否显示车辆速度
    params.scenario_gui.text_x_dev = 2; % 推演检查界面的文字x方向偏移
    params.scenario_gui.text_y_dev = 2; % 推演检查界面的文字y方向偏移
    params.scenario_gui.font_size = 8;  % 推演检查界面的文字大小
    


    %% 云端周车跟踪设置
    params.maxVehNum = 60;            %最多追踪多少辆周车
    params.egoClass = 2;              % 1 Car 2 Truck
    params.egoLength = 18;            % m 自车总长度
    params.egoWidth = 2.55;           % m 自车宽度
    params.egoHight = 3.5;            % m 自车高度
    params.egoColor = [1 0.7 0.5];    % RGB 橙色

    %% 车辆参数更新（观测）
    params.lc_thred = 0.5;            % m 偏离车道中心多少算作正在换道状态
    params.rushness_dict = dictionary(string([]),[]); % 自车纵向跟驰模型的delta，加速急不急，一般小车是4
    params.rushness_dict('private') = 4;
    params.rushness_dict('bus') = 3;
    params.rushness_dict('truck') = 2;
    params.rushness_dict('trailer') = 1.5;
    %% 自车安全仲裁
    params.D_SAFE = 0.2;                % m 安全距离
    params.lc_default_dev = 3;          % m 用于安全仲裁的假设横向换道距离
    params.min_MEI_thred = -0.2;           % m/s 用于安全仲裁的最大MEI



    %% 杂项设置
    % 案例结果保存
    currentTime = datetime('now', 'Format', 'yyyy-MM-dd_HH-mm-ss'); % 1. 获取当前时间（精确到秒）
    timeStr = char(currentTime); % 2. 转换为字符串（char类型，可直接用于保存/输出）
    params.case_name = ['LygYc_no' num2str(params.case_number) '_' ...
        num2str(params.Avg_Stream) '_' params.Case_Name '_' timeStr];
    params.output_dir = ['output\' params.case_name];
    % 动图录制
    params.if_record_gif = false;     % 是否录制仿真动图（会拖慢仿真时间）
    params.gifName = 'LianYG_YanC_01.gif'; % 动图命名名称
    params.gifDelayTime = 0.1;        % 秒 动图两帧之间的实际间隔时间（非仿真时间，决定帧率）
 
    %% 生成路网图模型参数
    % 车道纵向的平均节点距离
    params.graph.avg_node_dist = 2.5;    % 车道纵向的平均节点距离

    % 车道属性特征
    params.graph.lane_feat.center = 0;   % 车道级的3条纵向节点集，车道中心线的特征
    params.graph.lane_feat.left = 1.0;   % 车道级的3条纵向节点集，车道左边缘的特征
    params.graph.lane_feat.right = 0.5;  % 车道级的3条纵向节点集，车道右边缘的特征
    params.graph.lane_feat.bound = 2.0;  % 车道级的3条纵向节点集，道路边缘的特征 
    params.graph.lane_feat.junction = 0.1; % Junction内的所有节点的特征

    % 车道类型特征
    params.graph.road_type_feat.highway_motorway = 1.0; % 不同车道类型的特征
    params.graph.road_type_feat.others = 0.0;           % 除了高速主干道以外的其他类型
    params.graph.junction_speedlim = 33.33;             % 交叉口处的限速

    % 边的特征
    params.graph.link_wight.next = -1.0; % 顺着道路连接方向的边的特征
    params.graph.link_wight.side_left = 2.0;  % 包含横向移动的边的特征向左
    params.graph.link_wight.side_right = 1.0; % 包含横向移动的边的特征向右
    params.graph.link_wight.junction = 0.0; % 路口连接的网状结构

    % 标记edge/lane/edge组合的起点终点
    params.graph.marker.start = 1;       % 自由终点
    params.graph.marker.end = -1;        % 自由起点

    % 弹性带方法松弛Junction节点位置参数
    params.graph.slack.stiffness = 1;     % 弹簧刚度系数
    params.graph.slack.dump = 0.5;        % 弹簧阻尼系数
    params.graph.slack.lr = 0.15;        % 学习率更新
    params.graph.slack.max_iter = 200;    % 最大迭代数
    params.graph.slack.tol = 1e-2;        % 收敛误差范围  
    params.graph.slack.repel = 150;         % 不同节点之间的排斥力刚度
    params.graph.slack.pure_contract_iter = 20; % 纯收缩的步数，此步数后启用收缩+排斥
    params.graph.slack.clip = 0.5;        % 一次最多更新的大小 m

    % 用于可视化的colormap函数
    params.graph.vis.color_map_lanefeat = @(Graph) genColorMap_laneFeat(Graph); % 车道特征
    params.graph.vis.color_map_freeends = @(Graph) genColorMap_freeEnds(Graph); % 自由端点特征
    params.graph.vis.color_map_laneno = @(Graph) genColorMap_laneNo(Graph);     % 车道编号特征
    params.graph.vis.color_map_speedlim = @(Graph) genColorMap_speedlim(Graph); % 速度限制特征
    params.graph.vis.color_map_roadtype = @(Graph) genColorMap_roadType(Graph); % 道路类型特征

    params.graph.vis.color_map_vehspd = @(Graph) genColorMap_vehSpeed(Graph); % 车辆速度特征
    params.graph.vis.color_map_vehacc = @(Graph) genColorMap_vehAcc (Graph); % 车辆加速度特征
    params.graph.vis.color_map_vehocc = @(Graph) genColorMap_vehOcc (Graph); % 车辆占据概率特征
    params.graph.vis.color_map_vehhead = @(Graph) genColorMap_vehHead (Graph); % 车辆相对航向角特征
    params.graph.vis.color_map_vehego = @(Graph) genColorMap_vehEgo (Graph); % 车辆相对航向角特征
    params.graph.vis.color_map_vehroute = @(Graph) genColorMap_vehRoute (Graph); % 车辆相对航向角特征

    params.graph.vis.color_map_edgeside = @(Graph) genColorMap_edgeSide(Graph); % 边的方向特征



    % 用于计算车辆位置的高度增益系数
    params.graph.geometry.highway_height = 100; % m 高架桥的高度（用于在投影的时候过滤高架桥）

    % 子图地图大小
    params.graph.submap.range.front = 700;    % 主车前方截取的长度
    params.graph.submap.range.back = 300;     % 主车后方截取的长度

    % 车辆投影在子图上的情况
    params.graph.occ.longitudinalRadius = 5.8; % 纵向辐射半径更大，用于平滑车辆框外侧的节点赋予0~1的权重
    params.graph.occ.lateralRadius = 1.0;       % 横向辐射半径更小
    params.graph.occ.longitudinalSigma = 0.5;   % 纵向标准差
    params.graph.occ.lateralSigma = 0.3;        % 横向标准差
    params.graph.occ.searchPt = 100;         % 最多找到多少个点候选为某车
    params.graph.occ.searchRange = 35;       % 最多找到附近多少米的点（半径）

    % 车辆的意图
    params.graph.intention.cruise = 1;      % 车辆意图为巡航
    params.graph.intention.exit   = 2;      % 车辆意图为下匝道
    params.graph.intention.merge  = 3;      % 车辆意图为汇入

end

%% 辅助函数
function colorMat = genColorMap_vehRoute(Graph)
    vehRoute = Graph.Nodes.vehRouteMask;
    max_Intent = max(vehRoute);
    cmap = jet(256);
    colorMat = round(vehRoute/max_Intent*255)+1;
    colorMat(colorMat < 1) = 1;
    colorMat(colorMat > 256) = 256;
    colorMat = cmap(colorMat,:);
end


function colorMat = genColorMap_vehSpeed(Graph)
    vehSpd = Graph.Nodes.vehSpdMask;
    max_speed = max(vehSpd);
    cmap = jet(256);
    colorMat = round(vehSpd/max_speed*255)+1;
    colorMat(colorMat < 1) = 1;
    colorMat(colorMat > 256) = 256;
    colorMat = cmap(colorMat,:);
end

function colorMat = genColorMap_vehOcc(Graph)
    vehOcc = Graph.Nodes.vehMask;
    cmap = jet(256);
    colorMat = round(vehOcc*255)+1;
    colorMat(colorMat < 1) = 1;
    colorMat(colorMat > 256) = 256;
    colorMat = cmap(colorMat,:);
end

function colorMat = genColorMap_vehEgo(Graph)
    vehOcc = Graph.Nodes.vehEgoMask;
    cmap = jet(256);
    colorMat = round(vehOcc*255)+1;
    colorMat(colorMat < 1) = 1;
    colorMat(colorMat > 256) = 256;
    colorMat = cmap(colorMat,:);
end

function colorMat = genColorMap_vehHead(Graph)
    vehHead = Graph.Nodes.vehHeadMask;
    max_head = max(vehHead);
    min_head = min(vehHead);
    cmap = jet(256);
    colorMat = round((vehHead - min_head)/(max_head - min_head + 1e-3)*255)+1;
    colorMat(colorMat < 1) = 1;
    colorMat(colorMat > 256) = 256;
    colorMat = cmap(colorMat,:);
end

function colorMat = genColorMap_vehAcc(Graph)
    vehAcc = Graph.Nodes.vehAccMask;
    max_acc = max(vehAcc);
    min_acc = min(vehAcc);
    cmap = jet(256);
    colorMat = round((vehAcc - min_acc)/(max_acc - min_acc + 1e-4)*255)+1;
    colorMat(colorMat < 1) = 1;
    colorMat(colorMat > 256) = 256;
    colorMat = cmap(colorMat,:);
end

function colorMat = genColorMap_edgeSide(Graph)
       color_map= dictionary(-1,{[0 0 0]},0,{[1 0 1]},1,{[0 1 0]},2,{[1 0 0]}); % 用于可视化的colormap
    edges_colors = arrayfun(@(c) color_map{c}, round(Graph.Edges.Weight),'UniformOutput',false);
    colorMat = reshape([edges_colors{:}],3,[])';
end

function colorMat = genColorMap_laneFeat(Graph)

       color_map= dictionary(20,{[1 0 0]},0,{[1 1 0]},5,{[0 0 1]},10,{[0 1 0]},1,{[1,0,1]}); % 用于可视化的colormap
    nodes_colors = arrayfun(@(c) color_map{c}, round(Graph.Nodes.nodes_type_feat*10),'UniformOutput',false);
    colorMat = reshape([nodes_colors{:}],3,[])';
end
function colorMat = genColorMap_freeEnds(Graph)
    color_map= dictionary(-1,{[1 0 0]},0,{[0 0 1]},1,{[0 1 0]}); % 用于可视化的colormap
    nodes_colors = arrayfun(@(c) color_map{c}, round(Graph.Nodes.free_ends_feat),'UniformOutput',false);
    colorMat = reshape([nodes_colors{:}],3,[])';
end
function colorMat = genColorMap_laneNo(Graph)
    colorMat = Graph.Nodes.lane_number*ones(1,3);
    colorMat = colorMat + 1/3;
    colorMat = colorMat/max(colorMat,[],"all");
end
function colorMat = genColorMap_speedlim(Graph)
    max_speed = 33.33;
    cmap = jet(256);
    colorMat = round(Graph.Nodes.speed_lim/max_speed*255)+1;
    colorMat(colorMat < 1) = 1;
    colorMat(colorMat > 256) = 256;
    colorMat = cmap(colorMat,:);
end
function colorMat = genColorMap_roadType(Graph)
    cmap = jet(256);
    colorMat = round(Graph.Nodes.road_type*255)+1;
    colorMat(colorMat < 1) = 1;
    colorMat(colorMat > 256) = 256;
    colorMat = cmap(colorMat,:);
end
