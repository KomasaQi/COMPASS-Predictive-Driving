function [MEI, TEM, InDepth] = trailer_mei(tf, Ts, D_safe, ego_x, ego_y, ego_v, ego_head, ego_l, ego_w,...
    tractor_x, tractor_y, tractor_v, tractor_head, tractor_l, tractor_w, tractor_lb,...
    trailer_gamma, trailer_l, trailer_w)
    % 仿真参数设置
    t = 0:Ts:tf;
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
    
    TEM = inf;
    has_collide = false;
    for i = 1:length(t)
    
        trailer_corners = get_rect_poly_corners(trailer_center_x(i),trailer_center_y(i),trailer_head_s(i),trailer_l,trailer_w);
        res_dA(i) = max([cross2(trailer_corners(1,:)-[trailer_center_x(i),trailer_center_y(i)],trailer_thr_s(i,:)),...
                  cross2(trailer_corners(2,:)-[trailer_center_x(i),trailer_center_y(i)],trailer_thr_s(i,:))]);
        res_dB(i) = max([cross2(ego_corners(1,:),trailer_thr_s(i,:)),...
                  cross2(ego_corners(2,:),trailer_thr_s(i,:))]);
        res_Dc(i) = cross2([trailer_center_x(i),trailer_center_y(i)],trailer_thr_s(i,:));
        collision_res = intersect_polypoly_mex(ego_corners,trailer_corners);
        res_collision(i) = collision_res;
        if collision_res
            % disp(['第' num2str(i) '时刻发生相交' ])
            if ~has_collide
                has_collide = true;
                if i == 1
                    TEM = 1e-5;
                else
                    TEM = t(i);
                end
                
            end
        else
        end
    
    end
    
    
    InDepth = max((res_dA + res_dB - res_Dc + D_safe).*res_collision);
    % InDepth = max((res_dA + res_dB - res_Dc + D_safe));
    MEI = InDepth/TEM;
    if isinf(TEM)
        TEM = NaN;
        MEI = NaN;
    end
end