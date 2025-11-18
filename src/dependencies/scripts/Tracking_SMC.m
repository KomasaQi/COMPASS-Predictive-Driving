%% Tracking_SMC.m
% ------------------------------
% 改进版滑模控制轨迹跟踪程序
% 功能特性：
% 1. 模块化参数结构
% 2. 支持多种滑模面定义
% 3. 支持多种趋近律选择
% 4. 转向角速率限制保护
% 5. 修正车辆运动学模型
% ------------------------------
clc
% clear
close all
rng(0)

%% 参数定义（结构化存储）
global ControlParams %#ok
ControlParams.sys = struct(...
            'L', 2.9, ...           % 轴距 (m)
            'Ts', 0.02, ...         % 控制周期 (s)
            'v_tgt', 17, ...        % 目标速度 (m/s)
            'deltaMax', deg2rad(30),... % 最大转向角
            'axLimit', 3.0 ...      % 纵向加速度限制 (m/s²)
        );
        
        % 滑模控制器参数
ControlParams.smc = struct(...
            'K', [0.5, 1.2], ...    % 滑模面系数 [K_ey, K_eps]
            'eta', 0.8, ...         % 趋近律系数
            'sigma', 0.05, ...      % 指数项系数
            'phi', 0.1, ...         % 边界层厚度
            'rateLimit', deg2rad(180),...% 转向速率限制 (rad/s)
            'surfaceType', 'linear',... % 滑模面类型 [linear|terminal|integral]
            'reachingType', 'exponential'...% 趋近律类型 [constant|exponential|power]
        );
        
        % PID参数
ControlParams.pid = struct(...
            'Kp', 50, ...
            'Ki', 0.5, ...
            'Kd', 5 ...
        );

% 运行主程序
main()


%% 主程序
function main()
global ControlParams %#ok
    params = ControlParams; % 获取控制参数
    
    % 生成参考轨迹
    [refPath, curvature, ~] = generateReferencePath('SLC');
    
    % 初始化存储变量
    maxSteps = ceil(30/params.sys.Ts);
    log = struct(...
        'position', zeros(maxSteps,2),...
        'speed', zeros(maxSteps,1),...
        'heading', zeros(maxSteps,1),...
        'delta', zeros(maxSteps,1),...
        'time', (0:params.sys.Ts:(maxSteps-1)*params.sys.Ts)'...
    );
    
    % 初始状态
    state = struct(...
        'pos', [0, -1.4],...    % 初始位置
        'v', 15,...             % 初始速度
        'heading', 0.2,...      % 初始航向
        'delta', 0,...          % 初始转向角
        'a', 0,...              % 初始加速度
        'errInt', 0 ...         % 积分误差
    );
    
    % 主循环
    for step = 1:maxSteps
        % 记录状态
        log = recordState(log, state, step);
        
        % 路径跟踪
        [targetIdx, errors] = pathTrackingUpdate(state, refPath);
        kappa = curvature(targetIdx);

        % 滑模转向控制
        state.delta = slidingModeControl(errors, state, params, kappa);
        
        % PID速度控制
        state = speedControl(state, params);
        
        % 更新动力学
        state = updateVehicleDynamics(state, params.sys);
        
        % 终止条件
        if targetIdx >= size(refPath,1)-5, break; end
    end
    
    % 裁剪数据并可视化
    log = trimLog(log, step);
    visualizeResults(log, refPath);
end

%% 路径跟踪更新
function [targetIdx, errors] = pathTrackingUpdate(state, refPath)
    % 查找最近路径点
    targetIdx = findTargetIdx(state.pos, refPath(:,1:2));
    
    % 计算横向和航向误差
    [errors.ey, errors.epsi] = calcPathErrors(state, refPath, targetIdx);
end

function idx = findTargetIdx(pos, path)
    [~, idx] = min(vecnorm(path - pos, 2, 2));
end

function [ey, epsi] = calcPathErrors(state, path, idx)
    dx = state.pos(1) - path(idx,1);
    dy = state.pos(2) - path(idx,2);
    
    % 计算参考航向
    if idx == 1
        tangent = path(2,:) - path(1,:);
    else
        tangent = path(idx,:) - path(idx-1,:);
    end
    refHead = atan2(tangent(2), tangent(1));
    
    % 横向误差（Frenet坐标系）
    ey = -dx*sin(refHead) + dy*cos(refHead);
    
    % 航向误差（规范化到[-pi, pi]）
    epsi = state.heading - refHead;
    epsi = mod(epsi + pi, 2*pi) - pi;
end

%% 滑模控制器
function delta = slidingModeControl(errors, state, params, kappa)
    persistent s_prev
    if isempty(s_prev), s_prev = 0; end
    
    % 计算滑模面
    switch params.smc.surfaceType
        case 'linear'
            s = params.smc.K(1)*errors.ey + params.smc.K(2)*errors.epsi;
        case 'terminal'
            alpha = 0.6;
            s = params.smc.K(1)*sign(errors.ey)*abs(errors.ey)^alpha + ...
                params.smc.K(2)*sign(errors.epsi)*abs(errors.epsi)^alpha;
        case 'integral'
            s_int = s_prev + errors.ey*params.sys.Ts;
            s = params.smc.K(1)*errors.ey + params.smc.K(2)*errors.epsi + 0.1*s_int;
            s_prev = s_int;
    end
    
    % 计算趋近律
    switch params.smc.reachingType
        case 'constant'
            s_dot_des = -params.smc.eta*sat(s/params.smc.phi);
        case 'exponential'
            s_dot_des = -params.smc.eta*sat(s/params.smc.phi) - params.smc.sigma*s;
        case 'power'
            gamma = 0.5;
            s_dot_des = -params.smc.eta*abs(s)^gamma*sign(s) - params.smc.sigma*s;
    end
    
    % 误差动态项
    ey_dot = state.v * sin(errors.epsi);
    % kappa = getCurvature(state.pos, params.sys.L); % 曲率获取函数需根据实际情况实现
    
    % 控制方程求解
    numerator = s_dot_des - params.smc.K(1)*ey_dot + params.smc.K(2)*state.v*kappa;
    tan_delta = (numerator * params.sys.L) / (params.smc.K(2)*state.v);
    
    % 转向角计算与限制
    delta_cmd = atan(tan_delta);
    delta = applySteeringLimits(delta_cmd, state.delta, params);
end

function delta = applySteeringLimits(delta_cmd, delta_prev, params)
    % 速率限制
    delta_rate = (delta_cmd - delta_prev)/params.sys.Ts;
    delta_rate = sign(delta_rate)*min(abs(delta_rate), params.smc.rateLimit);
    
    % 幅值限制
    delta = delta_prev + delta_rate*params.sys.Ts;
    delta = sign(delta)*min(abs(delta), params.sys.deltaMax);
end

%% PID速度控制
function state = speedControl(state, params)
    persistent e_prev
    if isempty(e_prev), e_prev = 0; end
    
    e = params.sys.v_tgt - state.v;
    state.errInt = state.errInt + e*params.sys.Ts;
    derr = (e - e_prev)/params.sys.Ts;
    
    a = params.pid.Kp*e + params.pid.Ki*state.errInt + params.pid.Kd*derr;
    state.a = sign(a)*min(abs(a), params.sys.axLimit);
    e_prev = e;
end

%% 车辆动力学更新
function state = updateVehicleDynamics(state, sysParams)
    % 位置更新
    state.pos = state.pos + state.v * sysParams.Ts * ...
        [cos(state.heading), sin(state.heading)];
    
    % 航向更新
    state.heading = state.heading + (state.v / sysParams.L) * ...
        tan(state.delta) * sysParams.Ts;
    state.heading = mod(state.heading + pi, 2*pi) - pi;
    
    % 速度更新
    state.v = state.v + state.a * sysParams.Ts;
    state.v = max(state.v, 0); % 速度非负
end

%% 辅助函数
function y = sat(x)
    y = min(max(x, -1), 1);
end

function log = recordState(log, state, step)
    log.position(step,:) = state.pos;
    log.speed(step) = state.v;
    log.heading(step) = state.heading;
    log.delta(step) = state.delta;
end

function log = trimLog(log, validSteps)
    fields = fieldnames(log);
    for i = 1:length(fields)
        log.(fields{i}) = log.(fields{i})(1:validSteps-1,:);
    end
end

%% 可视化
function visualizeResults(log, refPath)
    figure('Name','跟踪效果分析', 'Position',[100 100 800 600])
    
    subplot(3,1,1)
    plot(refPath(:,1), refPath(:,2), 'b--', 'LineWidth',1.5), hold on
    plot(log.position(:,1), log.position(:,2), 'r-', 'LineWidth',1.2)
    title('轨迹跟踪效果'), xlabel('纵向位置 (m)'), ylabel('横向位置 (m)')
    legend('参考轨迹','实际轨迹'), grid on
    
    subplot(3,1,2)
    plot(log.time, log.speed, 'LineWidth',1.5)
    title('车速变化'), xlabel('时间 (s)'), ylabel('速度 (m/s)')
    ylim([0 25]), grid on
    
    subplot(3,1,3)
    plot(log.time, rad2deg(log.delta), 'LineWidth',1.5)
    title('前轮转角'), xlabel('时间 (s)'), ylabel('转向角 (°)')
    ylim([-35 35]), grid on
end


%% ============== 函数定义区 ==============
function [path, cur, len] = generateReferencePath(type)
    % 生成参考路径 (与原有代码接口兼容)
    switch type
        case 'SLC'
            [path, cur, len] = getSingleLaneChangePath(50, 'poly');
        case 'S'
            load S_path.mat path
            cur = curvature(path(:,1), path(:,2));
            len = xy2distance(path(:,1), path(:,2));
        case 'DLC'
            load DLCpathReal.mat path len
            cur = curvature(path(:,1), path(:,2));
        otherwise
            error('无效路径类型');
    end
end
