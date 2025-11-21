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
    
    %% 云端周车跟踪设置
    params.maxVehNum = 20;            %最多追踪多少辆周车
    params.egoClass = 2;              % 1 Car 2 Truck
    params.egoLength = 18;            % m 自车总长度
    params.egoWidth = 2.55;           % m 自车宽度
    params.egoHight = 3.5;            % m 自车高度
    params.egoColor = [1 0.7 0.5];    % RGB 橙色


    %% 杂项设置
    % 案例结果保存
    currentTime = datetime('now', 'Format', 'yyyy-MM-dd_HH-mm-ss'); % 1. 获取当前时间（精确到秒）
    timeStr = char(currentTime); % 2. 转换为字符串（char类型，可直接用于保存/输出）
    params.case_name = ['LianYG_YanC_no' num2str(params.case_number) '_' ...
        num2str(params.Avg_Stream) '_' params.Case_Name '_' timeStr];
    params.output_dir = ['output\' params.case_name];
    % 动图录制
    params.if_record_gif = false;     % 是否录制仿真动图（会拖慢仿真时间）
    params.gifName = 'LianYG_YanC_01.gif'; % 动图命名名称
    params.gifDelayTime = 0.1;        % 秒 动图两帧之间的实际间隔时间（非仿真时间，决定帧率）
 



end




