function vehMask = computeVehicleOccupancyMask(pos, shape_square, varargin)
    % COMPUTEVEHICLEOCCUPANCYMASK （改进版）计算二维点云的车辆占据掩码（支持纵横向独立参数）
    % 输入参数：
    %   pos - 二维点云数据，n×2 矩阵（每一行对应一个点的x、y坐标）
    %   shape_square - 车辆四边形角点，4×2 矩阵（FL/FR/RR/RL 顺时针/逆时针排列）
    %   varargin - 可选参数（键值对形式）：
    %       'SmoothType' - 平滑衰减类型，可选 'gaussian'（高斯，默认）/ 'linear'（线性）
    %       'LongitudinalRadius' - 纵向平滑半径（车头-车尾方向），默认 0.8（与点云单位一致）
    %       'LateralRadius' - 横向平滑半径（车左-车右方向），默认 0.3（与点云单位一致）
    %       'LongitudinalSigma' - 纵向高斯标准差，默认 LongitudinalRadius/3
    %       'LateralSigma' - 横向高斯标准差，默认 LateralRadius/3
    % 输出参数：
    %   vehMask - 点云占据掩码，n×1 向量，值范围 [0,1]
    
    %% 1. 参数初始化与校验
    % 默认参数（纵横向独立配置）
    params = struct(...
        'SmoothType', 'gaussian', ...
        'LongitudinalRadius', 0.8, ... % 纵向（车头-车尾）半径
        'LateralRadius', 0.3, ...      % 横向（车左-车右）半径
        'LongitudinalSigma', [],  ...  % 纵向标准差
        'LateralSigma', []);        % 横向标准差
    
    % 解析可选参数
    for i = 1:2:length(varargin)
        key = varargin{i};
        value = varargin{i+1};
        if isfield(params, key)
            params.(key) = value;
        else
            warning('未知参数：%s，已忽略', key);
        end
    end
    
    % 补全Sigma默认值（3σ原则）
    if isempty(params.LongitudinalSigma)
        params.LongitudinalSigma = params.LongitudinalRadius / 3;
    end
    if isempty(params.LateralSigma)
        params.LateralSigma = params.LateralRadius / 3;
    end
    
    % 输入维度校验
    if size(pos, 2) ~= 2
        error('pos必须是n×2的二维点云矩阵！');
    end
    if size(shape_square, 1) ~= 4 || size(shape_square, 2) ~= 2
        error('shape_square必须是4×2的车辆角点矩阵！');
    end
    n = size(pos, 1);
    vehMask = zeros(n, 1);
    
    % 提取车辆角点（FL/FR/RR/RL）
    FL = shape_square(1, :); FR = shape_square(2, :);
    RR = shape_square(3, :); RL = shape_square(4, :);
    
    %% 2. 构建车辆局部坐标系（解耦纵横向）
    % 步骤1：计算车辆中心点、车头/车尾中点
    center_front = (FL + FR) / 2;  % 车头中点
    center_rear = (RL + RR) / 2;   % 车尾中点
    center_veh = (center_front + center_rear) / 2;  % 车辆几何中心

    % 步骤2：定义纵轴和横轴单位向量
    vec_long = center_rear - center_front;  % 纵向向量（车头→车尾）
    vec_long = vec_long / norm(vec_long);   % 纵向单位向量
    vec_lat = [-vec_long(2), vec_long(1)];  % 横向向量（车左→车右，垂直于纵向）
    vec_lat = vec_lat / norm(vec_lat);      % 横向单位向量
    
    % 步骤3：构建坐标变换矩阵（全局→车辆局部）
    % 旋转矩阵（将全局坐标旋转至车辆局部坐标系）
    R = [vec_long; vec_lat];
    % 平移矩阵（将车辆中心移至局部坐标系原点）
    T = center_veh;
    
    %% 3. 判断点是否在车辆四边形内部
    square_x = shape_square(:, 1);
    square_y = shape_square(:, 2);
    [in_flag, ~] = inpolygon(pos(:, 1), pos(:, 2), square_x, square_y);
    vehMask(in_flag) = 1;  % 内部点占据比例置1
    
    %% 4. 外部点处理：全局→局部坐标转换
    out_idx = ~in_flag;
    out_pos_global = pos(out_idx, :);
    m = sum(out_idx);
    out_pos_local = zeros(m, 2);  % 局部坐标系下的外部点坐标
    
    % 坐标变换：P_local = R * (P_global - T)' （行向量转换）
    for i = 1:m
        p_global = out_pos_global(i, :) - T;
        out_pos_local(i, :) = p_global * R';  % 得到局部坐标（long, lat）
    end
    
    %% 5. 计算外部点到车辆的纵横向最短距离
    % 步骤1：将车辆角点转换到局部坐标系
    shape_square_local = zeros(4, 2);
    for i = 1:4
        p_global = shape_square(i, :) - T;
        shape_square_local(i, :) = p_global * R';
    end
    
    % 步骤2：定义车辆局部坐标系下的4条边
    edges = [1 2; 2 3; 3 4; 4 1];
    d_long_out = zeros(m, 1);  % 纵向最短距离
    d_lat_out = zeros(m, 1);   % 横向最短距离

    % 遍历每个外部点，计算纵/横向最短距离
    for i = 1:m
        p_local = out_pos_local(i, :);
        min_dist_long = inf;
        min_dist_lat = inf;
        
        % 遍历每条边，计算点到线段的纵/横向距离
        for j = 1:size(edges, 1)
            p1_local = shape_square_local(edges(j, 1), :);
            p2_local = shape_square_local(edges(j, 2), :);
            
            % 计算点到线段的纵/横向偏差（局部坐标系下）
            [dist_long, dist_lat] = point2SegmentDistance_LongLat(p_local, p1_local, p2_local);
            if abs(dist_long) < abs(min_dist_long)
                min_dist_long = dist_long;
            end
            if abs(dist_lat) < abs(min_dist_lat)
                min_dist_lat = dist_lat;
            end
        end
        
        % 取绝对值（距离非负）
        d_long_out(i) = abs(min_dist_long);
        d_lat_out(i) = abs(min_dist_lat);
    end

    %% 6. 纵横向独立的平滑衰减计算
    switch lower(params.SmoothType)
        case 'gaussian'
            % 二维高斯衰减：纵横向分别加权，超出对应半径置0
            decay_long = exp(-d_long_out.^2 / (2 * params.LongitudinalSigma^2));
            decay_lat = exp(-d_lat_out.^2 / (2 * params.LateralSigma^2));
            decay = decay_long .* decay_lat;  % 纵横向衰减叠加
            % 超出纵/横向半径的点置0
            decay(d_long_out > params.LongitudinalRadius | d_lat_out > params.LateralRadius) = 0;
            
        case 'linear'
            % 二维线性衰减：纵横向分别计算后叠加
            decay_long = (params.LongitudinalRadius - d_long_out) / params.LongitudinalRadius;
            decay_lat = (params.LateralRadius - d_lat_out) / params.LateralRadius;
            decay = decay_long .* decay_lat;
            % 超出半径或负数值置0
            decay(d_long_out > params.LongitudinalRadius | d_lat_out > params.LateralRadius) = 0;
            decay(decay < 0) = 0;
            
        otherwise
            error('不支持的平滑类型！可选''gaussian''或''linear''');
    end
    
    % 将衰减值赋值给外部点
    vehMask(out_idx) = decay;
    
    %% 7. 确保掩码值在[0,1]范围内
    vehMask = max(min(vehMask, 1), 0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dist_long, dist_lat] = point2SegmentDistance_LongLat(p0, p1, p2)
    % POINT2SEGMENTDISTANCE_LONGLAT 计算点到线段的纵/横向距离（局部坐标系下）
    % 输入：
    %   p0 - 局部坐标系下的待计算点，1×2 向量（long, lat）
    %   p1, p2 - 局部坐标系下的线段端点，1×2 向量（long, lat）
    % 输出：
    %   dist_long - 纵向距离（沿车辆车头→车尾方向）
    %   dist_lat - 横向距离（沿车辆车左→车右方向）
    
    % 向量计算
    vec_p1p0 = p0 - p1;
    vec_p1p2 = p2 - p1;
    len_p1p2 = norm(vec_p1p2);
    
    % 若线段长度为0（两点重合），直接返回点到点的纵横向偏差
    if len_p1p2 < 1e-8
        dist_long = vec_p1p0(1);
        dist_lat = vec_p1p0(2);
        return;
    end
    
    % 投影系数t（p0在p1p2上的投影位置）
    t = dot(vec_p1p0, vec_p1p2) / (len_p1p2^2);
    
    % 根据t判断投影位置，计算纵横向距离
    if t <= 0
        % 投影在p1外侧，距离为p0到p1的纵横向偏差
        dist_long = vec_p1p0(1);
        dist_lat = vec_p1p0(2);
    elseif t >= 1
        % 投影在p2外侧，距离为p0到p2的纵横向偏差
        dist_long = p0(1) - p2(1);
        dist_lat = p0(2) - p2(2);
    else
        % 投影在线段内部，计算点到线段的纵横向垂直偏差
        proj_p = p1 + t * vec_p1p2;  % 投影点坐标
        dist_long = p0(1) - proj_p(1);
        dist_lat = p0(2) - proj_p(2);
    end
end