% 车辆参数设置（与Python示例相同）
% 主车参数 (Vehicle A)
x_A = 0;   % X坐标 (m)
y_A = 0;    % Y坐标 (m)
v_A = 0.1;    % 速度 (m/s)
h_A = 0;   % 航向角 (弧度)
l_A = 10;  % 车长 (m)
w_A = 2.5;  % 车宽 (m)

% 目标车参数 (Vehicle B)
x_B = -2;    % X坐标 (m)
y_B = 8;    % Y坐标 (m)
v_B = 5;  % 速度 (m/s)
h_B = -1;    % 航向角 (弧度)
l_B = 4.8;   % 车长 (m)
w_B = 1.8;  % 车宽 (m)


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

% 计算安全指标（假设ssm_q函数已定义）
[ACT, v_closest, Shortest_D, InDepth, MEI, TEM, DTC, v_norm] = ssm_q(veh_A, veh_B, D_safe);

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


% ====================== 可视化展示部分 ======================
figure('Name','车辆安全指标可视化','Position',[100 100 800 600]);
hold on; grid on; axis equal;

% 1. 绘制车辆（矩形表示，考虑航向角旋转）
% 车辆A的四个顶点计算（考虑旋转）
corners_A = get_vehicle_corners(veh_A.x, veh_A.y, veh_A.h, veh_A.l, veh_A.w);
fill(corners_A(:,1), corners_A(:,2), [0.8 0.8 1], 'EdgeColor','b', 'LineWidth',1.5); % 浅蓝色车辆A

% 车辆B的四个顶点计算
corners_B = get_vehicle_corners(veh_B.x, veh_B.y, veh_B.h, veh_B.l, veh_B.w);
fill(corners_B(:,1), corners_B(:,2), [1 0.8 0.8], 'EdgeColor','r', 'LineWidth',1.5); % 浅红色车辆B

% 2. 绘制速度箭头（沿航向角方向，长度与速度成正比）
speed_scale = 0.5; % 速度箭头缩放比例
% 车辆A速度箭头
quiver(veh_A.x, veh_A.y, ...
       veh_A.v*cos(veh_A.h)*speed_scale, ...
       veh_A.v*sin(veh_A.h)*speed_scale, ...
       'b', 'LineWidth',2, 'MaxHeadSize',1);

% 车辆B速度箭头
quiver(veh_B.x, veh_B.y, ...
       veh_B.v*cos(veh_B.h)*speed_scale, ...
       veh_B.v*sin(veh_B.h)*speed_scale, ...
       'r', 'LineWidth',2, 'MaxHeadSize',1);

% 3. 标注车辆信息
text(veh_A.x + 1, veh_A.y + 1, ...
     sprintf('车辆A\nv=%.1fm/s\nh=%.2frad', veh_A.v, veh_A.h), ...
     'Color','b', 'FontSize',9);

text(veh_B.x + 1, veh_B.y + 1, ...
     sprintf('车辆B\nv=%.1fm/s\nh=%.2frad', veh_B.v, veh_B.h), ...
     'Color','r', 'FontSize',9);

% 4. 标注最短距离
% 计算最近点（复用之前的逻辑）
[~, closest_pts] = compute_shortest_distance(veh_A.x, veh_A.y, veh_A.v, veh_A.h, veh_A.l, veh_A.w, ...
                                             veh_B.x, veh_B.y, veh_B.v, veh_B.h, veh_B.l, veh_B.w);
closest_A = closest_pts{1};
closest_B = closest_pts{2};
plot([closest_A(1), closest_B(1)], [closest_A(2), closest_B(2)], 'k--', 'LineWidth',1); % 最短距离虚线
text(mean([closest_A(1), closest_B(1)]), mean([closest_A(2), closest_B(2)])+0.5, ...
     sprintf('最短距离: %.2fm', Shortest_D), 'Color','k', 'FontSize',8, 'BackgroundColor',[1 1 1 0.5]);

% 5. 标注关键安全指标
annotation('textbox', [0.05 0.05 0.3 0.2], ...
           'String', {sprintf('ACT: %.2fs', ACT), ...
                      sprintf('TEM: %.2fs', TEM), ...
                      sprintf('InDepth:%.2fm',InDepth),...
                      sprintf('MEI: %.2fm/s', MEI)}, ...
           'BackgroundColor',[1 1 1 0.8], 'EdgeColor','k', 'FontSize',9);

% 6. 设置坐标轴范围和标签
x_range = [min([corners_A(:,1); corners_B(:,1)])-5, max([corners_A(:,1); corners_B(:,1)])+5];
y_range = [min([corners_A(:,2); corners_B(:,2)])-5, max([corners_A(:,2); corners_B(:,2)])+5];
xlim(x_range);
ylim(y_range);
xlabel('X坐标 (m)');
ylabel('Y坐标 (m)');
title('车辆位置与安全指标可视化');
legend('车辆A', '车辆B', '速度方向', '最短距离', 'Location','best');
hold off;


% ====================== 辅助函数 ======================
function corners = get_vehicle_corners(x, y, h, l, w)
    % 计算车辆矩形的四个顶点（考虑航向角旋转）
    corners = zeros(4, 2);
    % 局部坐标系下的半长和半宽
    half_l = l/2;
    half_w = w/2;
    % 旋转矩阵
    rot = [cos(h) -sin(h); sin(h) cos(h)];
    % 四个顶点的局部坐标
    local_corners = [half_l, half_w; 
                    -half_l, half_w; 
                    -half_l, -half_w; 
                    half_l, -half_w];
    % 旋转并转换到全局坐标
    for i = 1:4
        global_pt = rot * local_corners(i,:)' + [x; y];
        corners(i,:) = global_pt';
    end
    % 闭合多边形（回到第一个点）
    corners = [corners; corners(1,:)];
end

function [min_dist, closest_pts] = compute_shortest_distance(xA, yA, vA, hA, lA, wA, xB, yB, vB, hB, lB, wB)
    % 计算两车最近点（复用之前的逻辑，用于可视化最短距离）
    cornersA = get_vehicle_corners(xA, yA, hA, lA, wA);
    cornersB = get_vehicle_corners(xB, yB, hB, lB, wB);
    [min_dist, closestA, closestB] = get_shortest_distance(cornersA(1:4,:), cornersB(1:4,:));
    closest_pts = {closestA, closestB};
end

function [dist, closest] = point_to_segment_distance(p, v1, v2)
    len = sqrt((v1(1)-v2(1))^2 + (v1(2)-v2(2))^2);
    if len < 1e-10
        dist = sqrt((p(1)-v1(1))^2 + (p(2)-v1(2))^2);
        closest = v1;
        return;
    end
    t = max(0, min(1, dot([p(1)-v1(1); p(2)-v1(2)], [v2(1)-v1(1); v2(2)-v1(2)])/len^2));
    closest = v1 + t*(v2 - v1);
    dist = sqrt((p(1)-closest(1))^2 + (p(2)-closest(2))^2);
end

function [min_dist, closestA, closestB] = get_shortest_distance(cornersA, cornersB)
    min_dist = inf;
    closestA = [0,0];
    closestB = [0,0];
    for i = 1:4
        pA = cornersA(i,:);
        for j = 1:4
            pB1 = cornersB(j,:);
            pB2 = cornersB(mod(j,4)+1,:);
            [dist, closest] = point_to_segment_distance(pA, pB1, pB2);
            if dist < min_dist
                min_dist = dist;
                closestA = pA;
                closestB = closest;
            end
        end
        pB = cornersB(i,:);
        for j = 1:4
            pA1 = cornersA(j,:);
            pA2 = cornersA(mod(j,4)+1,:);
            [dist, closest] = point_to_segment_distance(pB, pA1, pA2);
            if dist < min_dist
                min_dist = dist;
                closestA = closest;
                closestB = pB;
            end
        end
    end
end