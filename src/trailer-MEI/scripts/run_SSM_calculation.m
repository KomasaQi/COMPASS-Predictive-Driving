% 车辆参数设置（与Python示例相同）
% 主车参数 (Vehicle A)
x_A = -2;   % X坐标 (m)
y_A = 8;    % Y坐标 (m)
v_A = 5;    % 速度 (m/s)
h_A = -1;   % 航向角 (弧度)
l_A = 4.8;  % 车长 (m)
w_A = 1.8;  % 车宽 (m)

% 目标车参数 (Vehicle B)
x_B = 0;    % X坐标 (m)
y_B = 0;    % Y坐标 (m)
v_B = 0.1;  % 速度 (m/s)
h_B = 0;    % 航向角 (弧度)
l_B = 10;   % 车长 (m)
w_B = 2.5;  % 车宽 (m)

veh_A.x = x_A;
veh_A.y = y_A;
veh_A.v = v_A;
veh_A.h = h_A;
veh_A.w = w_A;
veh_A.l = l_A;

veh_B.x = x_B;
veh_B.y = y_B;
veh_B.v = v_B;
veh_B.h = h_B;
veh_B.w = w_B;
veh_B.l = l_B;

D_safe = 0; % 安全距离

test_num = 10000;
tic 
for i = 1:test_num
% 计算安全指标
% [ACT, v_closest, Shortest_D, InDepth, MEI, RTTC, DTC, v_norm] = ...
%     compute_SSM_mex(x_A, y_A, v_A, h_A, l_A, w_A, x_B, y_B, v_B, h_B, l_B, w_B);
[ACT, v_closest, Shortest_D, InDepth, MEI, TEM, DTC, v_norm] = ssm_q(veh_A, veh_B, D_safe);
end
total_time = toc;
disp(['平均单次调用耗时：' num2str(total_time/test_num*1000) ' ms'])

% 显示结果
fprintf('===== 车辆安全指标计算结果 =====\n');
fprintf('ACT: %.4f s\n', ACT);
fprintf('v_closest: %.4f m/s\n', v_closest);
fprintf('Shortest_D: %.4f m\n', Shortest_D);
fprintf('-----------------------------\n');
fprintf('TEM: %.4f s\n', TEM);
fprintf('DTC: %.4f m\n', DTC);
fprintf('v_norm: %.4f m/s\n', v_norm);
fprintf('-----------------------------\n');
fprintf('InDepth: %.4f m\n', InDepth);
fprintf('MEI: %.4f m/s\n', MEI);
