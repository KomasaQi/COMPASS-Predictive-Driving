function [ACT, v_closest, Shortest_D, InDepth, MEI, TEM, DTC, v_norm] = ...
    compute_SSM(x_A, y_A, v_A, h_A, l_A, w_A, x_B, y_B, v_B, h_B, l_B, w_B, D_SAFE) %#codegen
    % 计算车辆间安全指标：ACT, TEM, MEI等
    % 输入参数：两车的坐标(x,y)、速度(v)、航向角(h)、长度(l)、宽度(w)、安全距离D_SAFE
    % 输出参数：各类安全指标

    % 碰撞检测
    collision_result = get_collision_A_and_B(x_A, y_A, x_B, y_B, h_A, h_B, l_A, w_A, l_B, w_B);
    
    if ~collision_result
        % 计算最短距离和相关量
        [shortest_distance, ~, v_closest] = ...
            compute_shortest_distance(x_A, y_A, v_A, h_A, l_A, w_A, x_B, y_B, v_B, h_B, l_B, w_B);
        
        % 计算TEM（对应Python中的RTTC）
        [TEM, DTC, v_norm] = compute_TEM(x_A, y_A, v_A, h_A, l_A, w_A, x_B, y_B, v_B, h_B, l_B, w_B);
        
        if v_closest > 0
            % 计算侵入深度
            InDepth = compute_InDepth(x_A, y_A, v_A, h_A, l_A, w_A, x_B, y_B, v_B, h_B, l_B, w_B, D_SAFE);
            
            if InDepth >= 0
                % 计算ACT和MEI
                ACT = shortest_distance / v_closest;
                if ~isnan(TEM) && TEM ~= 0
                    MEI = InDepth / TEM;
                else
                    MEI = NaN;
                end
            else
                MEI = NaN;
                ACT = NaN;
            end
        else
            InDepth = NaN;
            MEI = NaN;
            ACT = NaN;
        end
    else
        % 碰撞状态下所有指标为NaN
        InDepth = NaN;
        MEI = NaN;
        ACT = NaN;
        v_closest = NaN;
        shortest_distance = NaN;
        TEM = NaN;
        DTC = NaN;
        v_norm = NaN;
    end
    
    Shortest_D = shortest_distance;


    % ================== 辅助函数定义 ==================
    function collision = get_collision_A_and_B(x_A, y_A, x_B, y_B, h_A, h_B, l_A, w_A, l_B, w_B)
        % 检测两矩形车辆是否碰撞（基于分离轴定理）
        [axes, max_min1, max_min2] = get_projection_offsets(l_A, w_A, h_A, l_B, w_B, h_B);
        A_series = [x_A, y_A];  % A车中心坐标
        B_series = [x_B, y_B];  % B车中心坐标
        collision = check_collisions_between_series(A_series, B_series, axes, max_min1, max_min2);
    end

    function [axes, max_min1, max_min2] = get_projection_offsets(l1, w1, h1, l2, w2, h2)
        % 计算分离轴及矩形在各轴上的投影范围（与Python逻辑一致）
        dx1 = l1 / 2; dy1 = w1 / 2;
        dx2 = l2 / 2; dy2 = w2 / 2;
        
        % 矩形顶点（局部坐标系）
        vertices1 = [ dx1, dy1; -dx1, dy1; -dx1, -dy1; dx1, -dy1];
        vertices2 = [ dx2, dy2; -dx2, dy2; -dx2, -dy2; dx2, -dy2];
        
        % 旋转矩阵（转换到全局坐标系）
        rot1 = [cos(h1), -sin(h1); sin(h1), cos(h1)];
        rot2 = [cos(h2), -sin(h2); sin(h2), cos(h2)];
        
        % 旋转顶点
        rot_vertices1 = vertices1 * rot1';
        rot_vertices2 = vertices2 * rot2';
        
        % 计算分离轴（每个矩形取2个相邻边的法线，共4个轴）
        axes = zeros(4, 2);
        
        % 矩形1的2个分离轴（取前2个边）
        for i = 1:2
            prev_idx = i - 1;
            if prev_idx == 0, prev_idx = 4; end  % 循环取前一个顶点
            edge = rot_vertices1(i, :) - rot_vertices1(prev_idx, :);  % 边向量
            axis_vec = [-edge(2), edge(1)];  % 法线方向（垂直边向量）
            axes(i, :) = axis_vec / norm(axis_vec);  % 单位化
        end
        
        % 矩形2的2个分离轴（取前2个边）
        for i = 1:2
            prev_idx = i - 1;
            if prev_idx == 0, prev_idx = 4; end  % 循环取前一个顶点
            edge = rot_vertices2(i, :) - rot_vertices2(prev_idx, :);  % 边向量
            axis_vec = [-edge(2), edge(1)];  % 法线方向
            axes(i + 2, :) = axis_vec / norm(axis_vec);  % 单位化，存放在3-4行
        end
        
        % 计算每个轴上的投影范围（矩形顶点投影的 min 和 max）
        max_min1 = zeros(4, 2);  % 矩形1在4个轴上的投影范围
        max_min2 = zeros(4, 2);  % 矩形2在4个轴上的投影范围
        for i = 1:4
            proj_val1 = rot_vertices1 * axes(i, :)';  % 矩形1所有顶点在轴i上的投影
            max_min1(i, :) = [min(proj_val1), max(proj_val1)];
            
            proj_val2 = rot_vertices2 * axes(i, :)';  % 矩形2所有顶点在轴i上的投影
            max_min2(i, :) = [min(proj_val2), max(proj_val2)];
        end
    end

    function collision = check_collisions_between_series(A, B, axes, max_min1, max_min2)
        % 检查两矩形在所有分离轴上的投影是否重叠（重叠则碰撞）
        collision = true;  % 初始假设碰撞
        for i = 1:4  % 检查4个分离轴
            % 计算A车中心在轴i上的投影 + 矩形1的投影偏移 = A车整体投影范围
            projA_center = dot(A, axes(i, :));
            projA_min = projA_center + max_min1(i, 1);
            projA_max = projA_center + max_min1(i, 2);
            
            % 计算B车整体投影范围
            projB_center = dot(B, axes(i, :));
            projB_min = projB_center + max_min2(i, 1);
            projB_max = projB_center + max_min2(i, 2);
            
            % 若任意轴上投影不重叠，则无碰撞
            if projA_max < projB_min || projB_max < projA_min
                collision = false;
                return;
            end
        end
    end

    function [TEM, DTC, v_norm] = compute_TEM(xA, yA, vA, hA, lA, wA, xB, yB, vB, hB, lB, wB)
        % 计算TEM（Time to Emergency Maneuver，对应Python的RTTC）
        rotA = [cos(hA), sin(hA); -sin(hA), cos(hA)];  % A车旋转矩阵
        rotB = [cos(hB), sin(hB); -sin(hB), cos(hB)];  % B车旋转矩阵
        
        % 计算边界框顶点（全局坐标）
        bboxA_base = [lA/2, wA/2; lA/2, -wA/2; -lA/2, -wA/2; -lA/2, wA/2];
        bboxB_base = [lB/2, wB/2; lB/2, -wB/2; -lB/2, -wB/2; -lB/2, wB/2];
        bboxA = repmat([xA, yA], 4, 1) + bboxA_base * rotA;
        bboxB = repmat([xB, yB], 4, 1) + bboxB_base * rotB;
        
        % 相对速度向量
        vA_vec = [vA * cos(hA); vA * sin(hA)];
        vB_vec = [vB * cos(hB); vB * sin(hB)];
        v_rel = vA_vec - vB_vec;
        v_norm = norm(v_rel);
        
        DTC = inf;  % 最小距离（Distance to Collision）
        % 检查A车顶点到B车边的射线相交
        for i = 1:4
            for j = 1:4
                next_j = mod(j, 4) + 1;  % B车边的下一个顶点
                dist = is_ray_intersect_segment(...
                    bboxA(i, 1), bboxA(i, 2), v_rel(1), v_rel(2), ...
                    bboxB(j, 1), bboxB(j, 2), bboxB(next_j, 1), bboxB(next_j, 2));
                if ~isempty(dist) && dist(1) > 0
                    DTC = min(DTC, dist(1));
                end
            end
        end
        % 检查B车顶点到A车边的射线相交
        for i = 1:4
            for j = 1:4
                next_j = mod(j, 4) + 1;  % A车边的下一个顶点
                dist = is_ray_intersect_segment(...
                    bboxB(i, 1), bboxB(i, 2), -v_rel(1), -v_rel(2), ...
                    bboxA(j, 1), bboxA(j, 2), bboxA(next_j, 1), bboxA(next_j, 2));
                if ~isempty(dist) && dist(1) > 0
                    DTC = min(DTC, dist(1));
                end
            end
        end
        
        % 计算TEM
        if isfinite(DTC) && v_norm > 1e-12
            TEM = DTC / v_norm;
        else
            TEM = NaN;
            DTC = NaN;
            v_norm = NaN;
        end
    end

    function dist = is_ray_intersect_segment(ray_x, ray_y, dir_x, dir_y, seg_x1, seg_y1, seg_x2, seg_y2)
        % 检查射线与线段是否相交，返回相交距离
        ray_origin = [ray_x; ray_y];
        ray_dir = [dir_x; dir_y];
        seg_start = [seg_x1; seg_y1];
        seg_end = [seg_x2; seg_y2];
        
        v1 = ray_origin - seg_start;
        v2 = seg_end - seg_start;
        v3 = [-ray_dir(2); ray_dir(1)];  % 射线方向的垂直向量
        v3 = v3 / norm(v3);  % 单位化
        
        dot_val = dot(v2, v3);
        if abs(dot_val) < 1e-10  % 线段与射线方向平行
            cross_val = v1(1)*v2(2) - v1(2)*v2(1);
            if abs(cross_val) < 1e-10  % 共线
                t0 = dot(seg_start - ray_origin, ray_dir);
                t1 = dot(seg_end - ray_origin, ray_dir);
                if t0 >= 0 && t1 >= 0
                    dist = min(t0, t1);  % 取最近交点
                elseif t0 < 0 && t1 < 0
                    dist = [];  % 线段在射线反方向
                else
                    dist = 0;  % 射线起点在线段上
                end
                return;
            end
            dist = [];  % 平行不共线，无交点
            return;
        end
        
        % 非平行情况计算交点
        t1 = (v2(1)*v1(2) - v2(2)*v1(1)) / dot_val;  % 射线参数
        t2 = dot(v1, v3) / dot_val;  % 线段参数
        
        if t2 >= 0 && t2 <= 1  % 交点在线段上
            dist = t1;
        else
            dist = [];  % 交点不在线段上
        end
    end

    function [min_dist, closest_pts, v_closest] = compute_shortest_distance(xA, yA, vA, hA, lA, wA, xB, yB, vB, hB, lB, wB)
        % 计算两车之间的最短距离及接近速度
        cornersA = get_rect_corners(xA, yA, hA, lA, wA);  % A车四角
        cornersB = get_rect_corners(xB, yB, hB, lB, wB);  % B车四角
        
        [min_dist, closestA, closestB] = get_shortest_distance(cornersA, cornersB);
        
        % 计算接近速度（closest点的相对速度在连线方向的分量）
        delta_x = closestB(1) - closestA(1);
        delta_y = closestB(2) - closestA(2);
        norm_delta = sqrt(delta_x^2 + delta_y^2);
        
        if norm_delta > 0
            unit_vec = [delta_x / norm_delta; delta_y / norm_delta];
            vel_diff = [vB * cos(hB) - vA * cos(hA); vB * sin(hB) - vA * sin(hA)];
            v_closest = -dot(unit_vec, vel_diff);  % 接近速度（正值表示靠近）
        else
            v_closest = 0;
        end
        
        closest_pts = {closestA, closestB};
    end

    function corners = get_rect_corners(x, y, h, l, w)
        % 计算矩形车辆的四个角点（全局坐标）
        corners = zeros(4, 2);
        corners(1,:) = [x - l/2*cos(h) - w/2*sin(h), y - l/2*sin(h) + w/2*cos(h)];
        corners(2,:) = [x + l/2*cos(h) - w/2*sin(h), y + l/2*sin(h) + w/2*cos(h)];
        corners(3,:) = [x + l/2*cos(h) + w/2*sin(h), y + l/2*sin(h) - w/2*cos(h)];
        corners(4,:) = [x - l/2*cos(h) + w/2*sin(h), y - l/2*sin(h) - w/2*cos(h)];
    end

    function d = distance(p1, p2)
        % 两点间距离
        d = sqrt((p1(1)-p2(1))^2 + (p1(2)-p2(2))^2);
    end

    function [dist, closest] = point_to_segment_distance(p, v1, v2)
        % 点到线段的最短距离及最近点
        len = distance(v1, v2);
        if len < 1e-10  % 线段退化为点
            dist = distance(p, v1);
            closest = v1;
            return;
        end
        
        % 计算点在 segment 上的投影参数 t（0<=t<=1 表示在 segment 上）
        t = max(0, min(1, dot([p(1)-v1(1), p(2)-v1(2)], [v2(1)-v1(1), v2(2)-v1(2)]) / len^2));
        closest = [v1(1) + t*(v2(1)-v1(1)), v1(2) + t*(v2(2)-v1(2))];  % 最近点
        dist = distance(p, closest);
    end

    function [min_dist, closestA, closestB] = get_shortest_distance(cornersA, cornersB)
        % 计算两矩形间的最短距离及最近点对
        min_dist = inf;
        closestA = [0,0];
        closestB = [0,0];
        
        % 检查所有角点到对方边的距离
        for i = 1:4
            % A车角点到B车各边
            pA = cornersA(i,:);
            for j = 1:4
                pB1 = cornersB(j,:);
                pB2 = cornersB(mod(j,4)+1,:);  % B车边的另一端点
                [dist, closest] = point_to_segment_distance(pA, pB1, pB2);
                if dist < min_dist
                    min_dist = dist;
                    closestA = pA;
                    closestB = closest;
                end
            end
            % B车角点到A车各边
            pB = cornersB(i,:);
            for j = 1:4
                pA1 = cornersA(j,:);
                pA2 = cornersA(mod(j,4)+1,:);  % A车边的另一端点
                [dist, closest] = point_to_segment_distance(pB, pA1, pA2);
                if dist < min_dist
                    min_dist = dist;
                    closestA = closest;
                    closestB = pB;
                end
            end
        end
    end

    function InDepth = compute_InDepth(xA, yA, vA, hA, lA, wA, xB, yB, vB, hB, lB, wB, D_SAFE)
        % 计算侵入深度（InDepth）
        v_diff = [vB*cos(hB)-vA*cos(hA); vB*sin(hB)-vA*sin(hA)];  % 相对速度向量
        if norm(v_diff) < 1e-12  % 相对速度为0，无法计算
            InDepth = NaN;
            return;
        end
        
        theta_B_prime = v_diff / norm(v_diff);  % 相对速度方向单位向量
        delta = [xB - xA; yB - yA];  % 位置差向量
        % 计算垂直于相对速度方向的距离
        D_t1 = norm(delta - dot(delta, theta_B_prime)*theta_B_prime);
        
        % 计算A车在垂直方向的最大投影
        cornersA = get_rect_corners(0,0,hA,lA,wA);  % 局部坐标下的角点
        d_As = zeros(4,1);
        for i = 1:4
            vec = cornersA(i,:)';
            d_As(i) = norm(vec - dot(vec, theta_B_prime)*theta_B_prime);  % 垂直距离
        end
        d_A_max = max(d_As);
        
        % 计算B车在垂直方向的最大投影
        cornersB = get_rect_corners(0,0,hB,lB,wB);
        d_Bs = zeros(4,1);
        for i = 1:4
            vec = cornersB(i,:)';
            d_Bs(i) = norm(vec - dot(vec, theta_B_prime)*theta_B_prime);
        end
        d_B_max = max(d_Bs);
        
        % 计算最小安全距离（MFD）和侵入深度
        MFD = D_t1 - (d_A_max + d_B_max);
        InDepth = D_SAFE - MFD;
    end

end % 主函数结束

