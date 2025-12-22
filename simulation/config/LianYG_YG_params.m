%连云港-盐城仿真参数配置
function params = LianYG_YG_params()
    %% 仿真案例设置
    % 案例基本信息
    params.case_number = 1;      % 仿真案例代号（1~28）
    params.sampleTime = 0.1;     % DrivingScenario采样时间与SUMO同默认0.1s
    params.if_start_sim  = true; % 是否进行仿真 
    params.mat_data_name = 'ProcessedMap_lianyg_yanc.mat'; % 路网预处理文件名称
    params.vehicleID = 't_0';

    % 案例相关参数读取
    [params.sumo_file_name, ... % sumo仿真文件名称
     params.rou_file_name, ...  % sumo路线文件名称
     params.DepartTime, ...     % 自车发车标称时间
     params.InitTime, ...       % COMPASS仿真开始时间
     params.EndPosX, ...        % 案例结束X位置
     params.EndPosY, ...        % 案例结束Y位置
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
    params.graph.avg_node_dist = 5.0;    % 车道纵向的平均节点距离

    % 车道属性特征
    params.graph.lane_feat.center = 0;   % 车道级的3条纵向节点集，车道中心线的特征
    params.graph.lane_feat.left = 1.0;   % 车道级的3条纵向节点集，车道左边缘的特征
    params.graph.lane_feat.right = 0.5;  % 车道级的3条纵向节点集，车道右边缘的特征
    params.graph.lane_feat.bound = 2.0;  % 车道级的3条纵向节点集，道路边缘的特征 
    params.graph.lane_feat.junction = 0.1; % Junction内的所有节点的特征

    % 边的特征
    params.graph.link_wight.next = -0.5; % 顺着道路连接方向的边的特征
    params.graph.link_wight.side = 0.5;  % 包含横向移动的边的特征（可以修改成向左向右不同）
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



end




