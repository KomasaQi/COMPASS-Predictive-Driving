% clc,clear
%% 参数设置
% 计算参数
tf = 5;
Ts = 0.2;
t = 0:Ts:tf;
D_safe = 0;

% 可视化用速度缩放系数
speed_scale = 0.5; 

%% 车辆状态输入
% 自车（半挂车）
ego_x = -2;
ego_y = 14;
ego_v = 2;
ego_head = 0.8;
ego_lb = 1.5;
ego_l = 5;
ego_w = 1.8;

% 自车挂车
ego_trailer_gamma = 0.8;
ego_trailer_l = 8;
ego_trailer_w = 1.8;

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

%% 轨迹解析解与坐标转换
% 转换牵引车/挂车位置到自车坐标系
tractor_xr0_trans = tractor_x - ego_x;
tractor_yr0_trans = tractor_y - ego_y;
tractor_xr0 = tractor_xr0_trans*cos(-ego_head) - tractor_yr0_trans*sin(-ego_head);
tractor_yr0 = tractor_xr0_trans*sin(-ego_head) + tractor_yr0_trans*cos(-ego_head);
tractor_xg0_r = tractor_xr0 - tractor_lb*cos(tractor_head-ego_head);
tractor_yg0_r = tractor_yr0 - tractor_lb*sin(tractor_head-ego_head);

% 计算牵引车、挂车轨迹解析解（曳物线）
th = pi-2*atan(tan((pi+trailer_gamma)/2)*exp(tractor_v/trailer_l*t));
idxs_large = th > pi;
th(idxs_large) = th(idxs_large) - 2*pi;
idxs_small = th < -pi;
th(idxs_small) = th(idxs_small) + 2*pi;

trailer_x_self_s = -(trailer_l*(log(tan(th/2))+cos(th)) - trailer_l*(log(tan(-trailer_gamma/2))));
trailer_y_self_s = -(trailer_l*sin(th));
% 计算自车挂车转向角度解析解（曳物线）
ego_trailer_th = pi-2*atan(tan((pi+ego_trailer_gamma)/2)*exp(ego_v/ego_trailer_l*t));
idxs_large = ego_trailer_th > pi;
ego_trailer_th(idxs_large) = ego_trailer_th(idxs_large) - 2*pi;
idxs_small = ego_trailer_th < -pi;
ego_trailer_th(idxs_small) = ego_trailer_th(idxs_small) + 2*pi;

% 将解析解旋转+平移到自车坐标系下
rotation_head = tractor_head - ego_head;
trailer_xr_s = trailer_x_self_s*cos(rotation_head) - trailer_y_self_s*sin(rotation_head) + tractor_xg0_r;
trailer_yr_s = trailer_x_self_s*sin(rotation_head) + trailer_y_self_s*cos(rotation_head) + tractor_yg0_r;
tractor_x_self_s = t*tractor_v;
tractor_y_self_s = 0*t;
tractor_xr_s = tractor_x_self_s*cos(rotation_head) - tractor_y_self_s*sin(rotation_head) + tractor_xg0_r;
tractor_yr_s = tractor_x_self_s*sin(rotation_head) + tractor_y_self_s*cos(rotation_head) + tractor_yg0_r;

ego_trailer_xr_s = -cos(ego_trailer_th)*ego_trailer_l - ego_lb;
ego_trailer_yr_s = -sin(ego_trailer_th)*ego_trailer_l;
ego_trailer_center_xr_s = ego_trailer_xr_s/2 -ego_lb/2;
ego_trailer_center_yr_s = ego_trailer_yr_s/2;

% 计算挂车速度幅值序列
trailer_v_s = sqrt((tractor_v*cos(th)).^2 + (tractor_v*sin(th)/2).^2);
ego_trailer_v_s = sqrt((ego_v*cos(th)).^2 + (ego_v*sin(th)/2).^2);

% 将牵引车挂车坐标时空投影到自车坐标
ego_x_self_s = ego_v*t;
trailer_xr_s = trailer_xr_s - ego_x_self_s;
tractor_xr_s = tractor_xr_s - ego_x_self_s;
trailer_center_x = (trailer_xr_s + tractor_xr_s)/2;
trailer_center_y = (trailer_yr_s + tractor_yr_s)/2;
trailer_head_s = atan2(tractor_yr_s-trailer_yr_s,tractor_xr_s-trailer_xr_s);
trailer_vr_s = [(trailer_v_s.*cos(trailer_head_s) - ego_v)',(trailer_v_s.*sin(trailer_head_s))'];
trailer_thr_s = trailer_vr_s./sqrt((trailer_vr_s(:,1)).*trailer_vr_s(:,1) + (trailer_vr_s(:,2)).*trailer_vr_s(:,2));

ego_trailer_vr_s = [(ego_trailer_v_s.*cos(ego_trailer_th) - ego_v)',(ego_trailer_v_s.*sin(ego_trailer_th))'];
ego_trailer_thr_s = ego_trailer_v_s./sqrt((ego_trailer_v_s(:,1)).*ego_trailer_v_s(:,1) + (ego_trailer_v_s(:,2)).*ego_trailer_v_s(:,2));

vr_s = trailer_vr_s - ego_trailer_vr_s;
thr_s = vr_s./sqrt((vr_s(:,1)).*vr_s(:,1) + (vr_s(:,2)).*vr_s(:,2));
%% 计算替代安全指标
% 预分配存储空间
res_dA = zeros(length(t),1);
res_dB = zeros(length(t),1);
res_Dc = zeros(length(t),1);
res_collision = false(length(t),1);

ego_corners = get_rect_poly_corners(0,0,0,ego_l,ego_w);

figure('Name','两半挂车安全指标可视化','Position',[100 100 800 600])
clf
hold on
corners = get_rect_poly_corners(0,0,0,ego_l,ego_w);
fill(ego_corners(:,1),ego_corners(:,2),'m','FaceAlpha',0.2)
plot(trailer_xr_s,trailer_yr_s,'Color','b')
scatter(trailer_xr_s,trailer_yr_s,'filled','o','MarkerFaceColor','b')
plot(tractor_xr_s,tractor_yr_s,'Color','r')
scatter(tractor_xr_s,tractor_yr_s,'filled','o','MarkerFaceColor','r')
scatter(trailer_center_x,trailer_center_y,'filled','o','MarkerFaceColor','b')
scatter(ego_trailer_center_xr_s,ego_trailer_center_yr_s,'filled','o','MarkerFaceColor','b')
TEM = inf;
has_collide = false;
for i = 1:length(t)
    plot([tractor_xr_s(i) trailer_xr_s(i)],[tractor_yr_s(i) trailer_yr_s(i)],'Color','g')
    plot([-ego_lb ego_trailer_xr_s(i)],[0 ego_trailer_yr_s(i)],'Color','r')
    corners = get_rect_poly_corners(trailer_center_x(i),trailer_center_y(i),trailer_head_s(i),trailer_l,trailer_w);
    ego_trailer_corners = get_rect_poly_corners(ego_trailer_center_xr_s(i),ego_trailer_center_yr_s(i),ego_trailer_th(i),ego_trailer_l,ego_trailer_w);
    
    res_dA(i) = max([cross2(corners(1,:)-[trailer_center_x(i),trailer_center_y(i)],thr_s(i,:)),...
              cross2(corners(2,:)-[trailer_center_x(i),trailer_center_y(i)],thr_s(i,:))]);
    res_dB(i) = max([cross2(ego_trailer_corners(1,:)-[ego_trailer_center_xr_s(i),ego_trailer_center_yr_s(i)],thr_s(i,:)),...
              cross2(ego_trailer_corners(2,:)-[ego_trailer_center_xr_s(i),ego_trailer_center_yr_s(i)],thr_s(i,:))]);
    res_Dc(i) = cross2([trailer_center_x(i),trailer_center_y(i)]-[ego_trailer_center_xr_s(i),ego_trailer_center_yr_s(i)],trailer_thr_s(i,:));
    collision_res = intersect_polypoly_mex(ego_trailer_corners,corners);
    res_collision(i) = collision_res;
    if collision_res
        disp(['第' num2str(i) '时刻发生相交' ])
        if ~has_collide
            has_collide = true;
            TEM = t(i);
        end
    else
    end
    % 挂车占据空间矩形框
    fill(corners(:,1),corners(:,2),'g','FaceAlpha',0.03)
    fill(ego_trailer_corners(:,1),ego_trailer_corners(:,2),'y','FaceAlpha',0.03)
    % 挂车相对速度箭头
    quiver(trailer_center_x(i), trailer_center_y(i), ...
           trailer_vr_s(i,1)*speed_scale, ...
           trailer_vr_s(i,2)*speed_scale, ...
           'b', 'LineWidth',2, 'MaxHeadSize',1)
    quiver(ego_trailer_center_xr_s(i), ego_trailer_center_yr_s(i), ...
           ego_trailer_vr_s(i,1)*speed_scale, ...
           ego_trailer_vr_s(i,2)*speed_scale, ...
           'b', 'LineWidth',2, 'MaxHeadSize',1)
    quiver(trailer_center_x(i) + trailer_vr_s(i,1)*speed_scale,...
           trailer_center_y(i) + trailer_vr_s(i,2)*speed_scale, ...
           -ego_trailer_vr_s(i,1)*speed_scale, ...  
           -ego_trailer_vr_s(i,2)*speed_scale, ...
           'r', 'LineWidth',2, 'MaxHeadSize',1)
    quiver(trailer_center_x(i), trailer_center_y(i), ...
           vr_s(i,1)*speed_scale, ...
           vr_s(i,2)*speed_scale, ...
           'm', 'LineWidth',2, 'MaxHeadSize',1)

end
tractor_corners = get_rect_poly_corners(tractor_xr0,tractor_yr0,tractor_head-ego_head,tractor_l,tractor_w);
fill(tractor_corners(:,1),tractor_corners(:,2),'c','FaceAlpha',0.13)
scatter(0,0,50,"filled","o","MarkerFaceColor",'m')
axis equal
grid on;

InDepth = max((res_dA + res_dB - res_Dc + D_safe).*res_collision);
MEI = InDepth/TEM;

test_num = 1000;
tic
for num = 1:test_num
[MEI, TEM, InDepth] = trailer2_mei_mex(tf, Ts, D_safe, ego_x, ego_y, ego_v, ego_head, ego_l, ego_w, ego_lb,...
    ego_trailer_gamma, ego_trailer_l, ego_trailer_w,...
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