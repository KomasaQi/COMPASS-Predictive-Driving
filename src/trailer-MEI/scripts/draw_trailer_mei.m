t = 0:Ts:tf;
speed_scale = 0.5;
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
trailer_x_self_s = -(trailer_l*(log(tan(th/2))+cos(th)) - trailer_l*(log(tan(-trailer_gamma/2))));
trailer_y_self_s = -(trailer_l*sin(th));

% 将解析解旋转+平移到自车坐标系下
rotation_head = tractor_head - ego_head;
trailer_xr_s = trailer_x_self_s*cos(rotation_head) - trailer_y_self_s*sin(rotation_head) + tractor_xg0_r;
trailer_yr_s = trailer_x_self_s*sin(rotation_head) + trailer_y_self_s*cos(rotation_head) + tractor_yg0_r;
tractor_x_self_s = t*tractor_v;
tractor_y_self_s = 0*t;
tractor_xr_s = tractor_x_self_s*cos(rotation_head) - tractor_y_self_s*sin(rotation_head) + tractor_xg0_r;
tractor_yr_s = tractor_x_self_s*sin(rotation_head) + tractor_y_self_s*cos(rotation_head) + tractor_yg0_r;

% 计算挂车速度幅值序列
trailer_v_s = sqrt((tractor_v*cos(th)).^2 + (tractor_v*sin(th)/2).^2);

% 将牵引车挂车坐标时空投影到自车坐标
ego_x_self_s = ego_v*t;
trailer_xr_s = trailer_xr_s - ego_x_self_s;
tractor_xr_s = tractor_xr_s - ego_x_self_s;
trailer_center_x = (trailer_xr_s + tractor_xr_s)/2;
trailer_center_y = (trailer_yr_s + tractor_yr_s)/2;
trailer_head_s = atan2(tractor_yr_s-trailer_yr_s,tractor_xr_s-trailer_xr_s);
trailer_vr_s = [(trailer_v_s.*cos(trailer_head_s) - ego_v)',(trailer_v_s.*sin(trailer_head_s))'];
trailer_thr_s = trailer_vr_s./sqrt((trailer_vr_s(:,1)).*trailer_vr_s(:,1) + (trailer_vr_s(:,2)).*trailer_vr_s(:,2));

%% 计算替代安全指标
% 预分配存储空间
res_dA = zeros(length(t),1);
res_dB = zeros(length(t),1);
res_Dc = zeros(length(t),1);
res_collision = false(length(t),1);

ego_corners = get_rect_poly_corners(0,0,0,ego_l,ego_w);

figure('Name','单车+半挂车安全指标可视化','Position',[100 100 800 600])
clf
hold on
corners = get_rect_poly_corners(0,0,0,ego_l,ego_w);
fill(ego_corners(:,1),ego_corners(:,2),'m','FaceAlpha',0.2)
plot(trailer_xr_s,trailer_yr_s,'Color','b')
scatter(trailer_xr_s,trailer_yr_s,'filled','o','MarkerFaceColor','b')
plot(tractor_xr_s,tractor_yr_s,'Color','r')
scatter(tractor_xr_s,tractor_yr_s,'filled','o','MarkerFaceColor','r')
scatter(trailer_center_x,trailer_center_y,'filled','o','MarkerFaceColor','b')
TEM = inf;
has_collide = false;
for i = 1:length(t)
    plot([tractor_xr_s(i) trailer_xr_s(i)],[tractor_yr_s(i) trailer_yr_s(i)],'Color','g')
    corners = get_rect_poly_corners(trailer_center_x(i),trailer_center_y(i),trailer_head_s(i),trailer_l,trailer_w);
    
    res_dA(i) = max([cross2(corners(1,:)-[trailer_center_x(i),trailer_center_y(i)],trailer_thr_s(i,:)),...
              cross2(corners(2,:)-[trailer_center_x(i),trailer_center_y(i)],trailer_thr_s(i,:))]);
    res_dB(i) = max([cross2(ego_corners(1,:),trailer_thr_s(i,:)),...
              cross2(ego_corners(2,:),trailer_thr_s(i,:))]);
    res_Dc(i) = cross2([trailer_center_x(i),trailer_center_y(i)],trailer_thr_s(i,:));
    collision_res = intersect_polypoly_mex(ego_corners,corners);
    res_collision(i) = collision_res;
    if collision_res
        % disp(['第' num2str(i) '时刻发生相交' ])
        if ~has_collide
            has_collide = true;
            TEM = t(i);
        end
    else
    end
    % 挂车占据空间矩形框
    fill(corners(:,1),corners(:,2),'g','FaceAlpha',0.03)
    % 挂车相对速度箭头
    quiver(trailer_center_x(i), trailer_center_y(i), ...
           trailer_vr_s(i,1)*speed_scale, ...
           trailer_vr_s(i,2)*speed_scale, ...
           'b', 'LineWidth',2, 'MaxHeadSize',1)
end
tractor_corners = get_rect_poly_corners(tractor_xr0,tractor_yr0,tractor_head-ego_head,tractor_l,tractor_w);
fill(tractor_corners(:,1),tractor_corners(:,2),'c','FaceAlpha',0.13)
scatter(0,0,50,"filled","o","MarkerFaceColor",'m')
axis equal
grid on;

InDepth = max((res_dA + res_dB - res_Dc + D_safe).*res_collision);
MEI = InDepth/TEM;