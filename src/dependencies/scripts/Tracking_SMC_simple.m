clc
% clear
close all
rng(0)
%% 相关参数定义
K_ey = 0.5;     % 横向误差权重
K_eps = 1.2;    % 航向误差权重
eta = 0.8;      % 趋近律系数
sigma = 0.05;   % 平滑系数
phi = 0.1;      % 饱和函数边界层
kp = 50;        % 车速控制器参数
ki = 0.5;
kd = 5;
Ts = 0.02;      % 控制步长
L = 2.9;        % 轴距
v_tgt = 17;     % 目标速度
pathname = 'SLC';% 轨迹类型

%% 获得参考轨迹
if strcmp(pathname, 'SLC')
    [path, cur, len] = getSingleLaneChangePath(50, 'poly');
elseif strcmp(pathname, 'S')
    load S_path.mat;
    cur = curvature(path(:,1), path(:,2));
    len = xy2distance(path(:,1), path(:,2));
else
    error('请输入合法的轨迹名称');
end

% 参考航向角计算
diff_x = diff(path(:,1));
diff_y = diff(path(:,2));
refHead = atan2(diff_y, diff_x);
refHead(end+1) = refHead(end);

%% 主程序
position = zeros(size(path,1), 2);
speed = zeros(size(path,1), 1);
heading = zeros(size(path,1), 1);
Delta = zeros(size(path,1), 1);
time = (0:Ts:30)';

% 初始状态
pos = [0, -1.4];
spd = 15;
head = 0.2;
delta = 0;
e_prev = [0; 0]; % 误差导数初始化
ax = 0;

% 初始化仿真变量
iter = 0;
idx = 1;
while idx < size(path,1)
    iter = iter + 1;
    % 记录状态
    position(iter,:) = pos;
    speed(iter) = spd;
    heading(iter) = head;
    Delta(iter) = delta;
    
    % 获取最近路径点和曲率
    idx = findTargetIdx(pos, path(:,[1 2]));
    curvature_ref = cur(idx);
    
    % 计算横向误差和航向误差
    [ey, epsi] = calcErrors(pos, head, path, idx);
    
    % 滑模控制器计算前轮转角
    delta = smcController(ey, epsi, spd, curvature_ref, L, K_ey, K_eps, eta, sigma, phi, Ts, delta);
    
    % PID速度控制
    e = [e_prev; v_tgt - spd];
    ax = vxPID(e, ax, kp, ki, kd, Ts);
    e_prev = e(2:3);
    
    % 更新车辆状态
    pos = pos + spd * Ts * [cos(head), sin(head)];
    head = head + spd * Ts * tan(delta) / L;
    spd = spd + ax * Ts;
end

% 裁剪数据
position(iter:end,:) = [];
speed(iter:end) = [];
heading(iter:end) = [];
Delta(iter:end) = [];
time(iter:end) = [];

%% 绘图
figure(1)
subplot(3,1,1)
plot(path(:,1), path(:,2), 'b'); hold on;
plot(position(:,1), position(:,2), 'r');
title('轨迹对比'); xlabel('x/m'); ylabel('y/m'); hold off;

subplot(3,1,2)
plot(time, speed);
title('车速'); xlabel('时间/s'); ylabel('速度 m/s');

subplot(3,1,3)
plot(time, Delta * 180/pi);
title('前轮转角'); xlabel('时间/s'); ylabel('角度/°');

%% 子函数：计算横向和航向误差
function [ey, epsi] = calcErrors(pos, head, path, idx)
    % 参考点切向量
    if idx == 1
        tangent = path(2,:) - path(1,:);
    else
        tangent = path(idx,:) - path(idx-1,:);
    end
    tangent = tangent / norm(tangent);
    ref_head = atan2(tangent(2), tangent(1));
    
    % 横向误差
    dx = pos(1) - path(idx,1);
    dy = pos(2) - path(idx,2);
    ey = -dx * sin(ref_head) + dy * cos(ref_head);
    
    % 航向误差
    epsi = head - ref_head;
    epsi = wrapToPi(epsi); % 限制在[-π, π]
end

%% 子函数：滑模控制器
function delta = smcController(ey, epsi, v, curvature, L, K_ey, K_eps, eta, sigma, phi, Ts, delta)
    % 滑模面
    S = K_ey * ey + K_eps * epsi;
    
    % 误差导数（简化近似）
    ey_dot = v * sin(epsi);
    epsi_dot = (v / L) * delta - v * curvature;
    
    % 趋近律
    S_dot = K_ey * ey_dot + K_eps * epsi_dot;
    S_dot_desired = -eta * sat(S / phi) - sigma * S;
    
    % 控制量求解
    delta0 = delta;
    delta_cmd = (S_dot_desired - K_ey * ey_dot) / (K_eps * v / L) + L * curvature;
    ddelta = delta_cmd - delta0;

    % 限幅和速率限制
    delta_max = deg2rad(30);
    rate_limit = deg2rad(180) * Ts;
    ddelta = sign(ddelta) * min(abs(ddelta), rate_limit);
    delta_cmd = delta0 + ddelta;
    delta = sign(delta_cmd) * min(abs(delta_cmd), delta_max);
end

%% 子函数：饱和函数
function y = sat(x)
    y = min(max(x, -1), 1);
end

%% 子函数：查找最近路径点（沿用现有代码）
function idx = findTargetIdx(pos, path)
    dist = vecnorm(path - pos, 2, 2);
    [~, idx] = min(dist);
end