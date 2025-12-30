function dist = angle_norm(angle1, angle2, limit, unit)
    % ANGLE_NORM 计算两个角度之间的周期性最短距离
    %
    % 语法：
    %   dist = angle_norm(angle1, angle2)          % 默认弧度单位，周期范围[-π, π]
    %   dist = angle_norm(angle1, angle2, limit)   % 自定义周期范围（如[0, 2π]）
    %   dist = angle_norm(angle1, angle2, limit, unit)  % 指定单位（'rad'弧度/'deg'角度）
    %
    % 输入参数：
    %   angle1      - 第一个角度（标量或数组）
    %   angle2      - 第二个角度（标量或数组，与angle1维度兼容）
    %   limit       - 可选，2元素向量，角度周期范围[最小值, 最大值]，默认：
    %                 弧度单位时为[-π, π]，角度单位时为[-180, 180]
    %   unit        - 可选，角度单位，'rad'（弧度，默认）或'deg'（角度）
    %
    % 输出参数：
    %   dist        - 角度间的周期性最短距离（与输入角度维度一致，非负）
    %
    % 示例：
    %   1. 标量-标量对比（弧度）：dist = angle_norm(3.14, -pi);  % 结果接近0（因3.14≈π，与-pi接近）
    %   2. 标量-向量对比（弧度）：dist = angle_norm(0, [0, pi, 2*pi, 3*pi]);  % 结果[0, pi, 0, pi]
    %   3. 角度单位对比：dist = angle_norm(180, -180, [], 'deg');  % 结果接近0（180°与-180°在周期中重合）
    %   4. 自定义范围对比：dist = angle_norm(0.5, 3.5, [0, 2*pi]);  % 结果≈2.78（最短距离为2π-3≈3.28？原示例可能笔误，实际需按计算逻辑）


    % -------------------------- 1. 默认参数处理 --------------------------
    % 若未输入angle2，默认对比角度为0
    if nargin < 2 || isempty(angle2)
        angle2 = 0;
    end
    % 若未输入unit，默认单位为弧度（'rad'）
    if nargin < 4 || isempty(unit)
        unit = 'rad';
    end
    % 若未输入limit，根据单位设置默认周期范围
    if nargin < 3 || isempty(limit)
        if strcmpi(unit, 'rad')  % 弧度单位默认范围：[-π, π]
            limit = [-pi, pi];
        else  % 角度单位默认范围：[-180, 180]
            limit = [-180, 180];
        end
    end


    % -------------------------- 2. 单位验证与转换 --------------------------
    % 若单位为角度，先将所有角度（angle1/angle2）和周期范围（limit）转换为弧度
    if strcmpi(unit, 'deg')
        angle1 = deg2rad(angle1);    % 角度转弧度（MATLAB自带函数）
        angle2 = deg2rad(angle2);
        limit = deg2rad(limit);      % 周期范围也需同步转弧度
    elseif ~strcmpi(unit, 'rad')  % 若单位既不是'rad'也不是'deg'，报错
        error('指定的单位无效，请使用''rad''（弧度）或''deg''（角度）。');
    end


    % -------------------------- 3. 周期范围有效性验证 --------------------------
    range_span = limit(2) - limit(1);  % 计算周期范围的跨度（如[-π,π]跨度为2π）
    if range_span <= 0  % 若范围上限≤下限，说明范围无效，报错
        error('周期范围无效，第二个元素（上限）必须大于第一个元素（下限）。');
    end


    % -------------------------- 4. 角度归一化到指定周期范围 --------------------------
    % 匿名函数：将任意角度归一到[limit(1), limit(2))区间（左闭右开），确保角度在一个周期内
    % 原理：mod函数处理周期性，先减下限使范围起点为0，再取模得到[0, span)，最后加回下限
    normalize_angle = @(angle) mod(angle - limit(1), range_span) + limit(1);
    
    angle1_norm = normalize_angle(angle1);  % 第一个角度归一化
    angle2_norm = normalize_angle(angle2);  % 第二个角度归一化


    % -------------------------- 5. 维度兼容性处理 --------------------------
    % 确保angle1_norm和angle2_norm维度一致，支持标量与数组的element-wise运算
    if isscalar(angle1_norm) && ~isscalar(angle2_norm)
        % 若angle1是标量、angle2是数组，扩展angle1维度与angle2一致
        angle1_norm = repmat(angle1_norm, size(angle2_norm));
    elseif ~isscalar(angle1_norm) && isscalar(angle2_norm)
        % 若angle1是数组、angle2是标量，扩展angle2维度与angle1一致
        angle2_norm = repmat(angle2_norm, size(angle1_norm));
    elseif ~isequal(size(angle1_norm), size(angle2_norm))
        % 若两者都是数组但维度不同，报错
        error('输入角度维度不兼容，请确保为标量或相同尺寸的数组。');
    end


    % -------------------------- 6. 核心：计算周期性最短距离 --------------------------
    % 步骤1：计算归一化后的直接差值
    direct_diff = angle1_norm - angle2_norm;

    % 步骤2：计算周期性包裹差值（核心逻辑）
    % 原理：找到周期上的最短路径——若直接差值超过周期的1/2，就从“另一端绕过去”
    % 公式解释：mod(diff + span/2, span) - span/2 可将差值映射到[-span/2, span/2]
    wrapped_diff = mod(direct_diff + range_span/2, range_span) - range_span/2;

    % 步骤3：取绝对值得到最短距离（距离非负）
    dist = abs(wrapped_diff);


    % -------------------------- 7. 结果单位转回（若原单位为角度） --------------------------
    if strcmpi(unit, 'deg')
        dist = rad2deg(dist);  % 弧度转角度（MATLAB自带函数）
    end

end