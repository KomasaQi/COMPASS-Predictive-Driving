% clc,clear
%% 参数设置
% 计算参数
tf = 5;
Ts = 0.2;
D_safe = 0;


%% 车辆状态输入
% 自车（普通车辆）
ego_x = -15;
ego_y = 2;
ego_v = 10;
ego_head = 0.8;
ego_l = 5;
ego_w = 1.8;

% 牵引车
tractor_x = -15;
tractor_y = 15;
tractor_v = 11.2;
tractor_head = 0.5;
tractor_lb = 1.5;
tractor_l = 6;
tractor_w = 2.5;
% 挂车
trailer_gamma = -1;
trailer_l = 11;
trailer_w = 2.5;


test_num = 1000;
tic
for num = 1:test_num

[MEI, TEM, InDepth] = trailer_mei_mex(tf, Ts, D_safe, ego_x, ego_y, ego_v, ego_head, ego_l, ego_w,...
    tractor_x, tractor_y, tractor_v, tractor_head, tractor_l, tractor_w, tractor_lb,...
    trailer_gamma, trailer_l, trailer_w);

end
total_time = toc;
disp(['平均单次调用耗时：' num2str(total_time/test_num*1000) ' ms'])
% 显示结果
fprintf('===== 挂车安全指标计算结果 =====\n');
fprintf('TEM: %.4f s\n', TEM);
fprintf('InDepth: %.4f m\n', InDepth);
fprintf('MEI: %.4f m/s\n', MEI);


% 计算安全指标
[ACT, v_closest, Shortest_D, InDepth, MEI, TEM, DTC, v_norm] = ...
    compute_SSM_mex(tractor_x, tractor_y, tractor_v, tractor_head, tractor_l, tractor_w,...
                    ego_x, ego_y, ego_v, ego_head, ego_l, ego_w, D_safe);
% 显示结果
fprintf('===== 牵引车安全指标计算结果 =====\n');
fprintf('TEM: %.4f s\n', TEM);
fprintf('InDepth: %.4f m\n', InDepth);
fprintf('MEI: %.4f m/s\n', MEI);

draw_trailer_mei