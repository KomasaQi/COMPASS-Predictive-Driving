function [src, tgt, insert_nodes_pos] = buildInterpolatedGraph(...
    starter_poss, ender_poss, starter_idxs, ender_idxs, old_total_node_num, avg_node_dist)

% 默认参数
if nargin < 6
    avg_node_dist = 5; % meters
end

m = size(starter_poss, 1);
n = size(ender_poss, 1);

% ==============================
% Step 1: 确定层数和节点数 (修复：确保层数计算正确)
% ==============================
if m == n
    min_dist = min(pdist2(starter_poss, ender_poss), [], 'all');
    if min_dist <= 0
        K = 0;
    else
        x_opt = round(min_dist / avg_node_dist);
        K = max(x_opt - 1, 0);
    end
    layer_sizes = repmat(m, 1, K);
else
    diff = abs(m - n);
    K = max(diff - 1, 0);
    if K > 0
        if m > n
            layer_sizes = m - (1:K); % 从 m-1 递减
        else
            layer_sizes = m + (1:K); % 从 m+1 递增
        end
    else
        % 处理 m≠n 但 |m-n|==1 的情况 (关键修复)
        layer_sizes = []; % 不插入层，直接连接 (但数量不同，需特殊处理)
    end
end

total_insert = sum(layer_sizes);
insert_nodes_pos = zeros(total_insert, 2);

% ==============================
% Step 2: 构建连接关系 (修复：确保每层连接完整)
% ==============================
% 预分配边列表 (关键修复：计算准确的边数)
max_edges = 0;
if K > 0
    % starter → layer1
    max_edges = max_edges + 2 * m;
    % 中间层连接
    for i = 1:length(layer_sizes)-1
        max_edges = max_edges + 2 * max(layer_sizes(i), layer_sizes(i+1));
    end
    % last layer → ender
    max_edges = max_edges + 2 * n;
else
    % 直连 (仅当 m==n 或 |m-n|==1)
    if m == n
        max_edges = m; % 一一对应
    else
        % |m-n|==1 时，按数量少的点集连接
        max_edges = min(m, n);
    end
end

src = zeros(max_edges, 1);
tgt = zeros(max_edges, 1);
edge_count = 0;

% 节点ID映射 (关键修复：避免ID溢出)
comp_start_id = old_total_node_num + 1;
layer_abs_ids = cumsum([0, layer_sizes]); % 每层起始ID
layer_abs_ids = comp_start_id + layer_abs_ids(1:end-1); % 转换为全局ID

% 初始化补充节点位置 (关键修复：避免初始位置过大)
all_points = [starter_poss; ender_poss];
global_mean = mean(all_points, 1);
insert_nodes_pos(:) = repmat(global_mean, total_insert, 1); % 初始位置

% 线性插值初始化 (关键修复：避免数值不稳定)
if K > 0
    idx = 1;
    for l = 1:K
        L = layer_sizes(l);
        t = l / (K + 1);
        s_part = starter_poss(1:min(m, L), :);
        e_part = ender_poss(1:min(n, L), :);
        % 补齐长度 (避免索引错误)
        if size(s_part,1) < L
            s_part = [s_part; repmat(s_part(end,:), L - size(s_part,1), 1)];
        end
        if size(e_part,1) < L
            e_part = [e_part; repmat(e_part(end,:), L - size(e_part,1), 1)];
        end
        insert_nodes_pos(idx:idx+L-1, :) = (1 - t) * s_part + t * e_part;
        idx = idx + L;
    end
end

% 构建边列表 (关键修复：确保连接完整)
if K > 0
    % starter → layer1
    L1 = layer_sizes(1);
    layer1_ids = layer_abs_ids(1) + (0:L1-1)';
    for i = 1:m
        if i == 1
            src(edge_count+1) = starter_idxs(i);
            tgt(edge_count+1) = layer1_ids(1);
            edge_count = edge_count + 1;
        elseif i == m
            src(edge_count+1) = starter_idxs(i);
            tgt(edge_count+1) = layer1_ids(end);
            edge_count = edge_count + 1;
        else
            % 确保索引有效 (修复连接缺失)
            j1 = min(i, L1);
            j2 = max(1, min(i-1, L1));
            src(edge_count + (1:2)) = starter_idxs(i);
            tgt(edge_count + (1:2)) = [layer1_ids(j1); layer1_ids(j2)];
            edge_count = edge_count + 2;
        end
    end

    % 中间层连接 (修复：处理节点数不等)
    for l = 1:K-1
        curr_size = layer_sizes(l);
        next_size = layer_sizes(l+1);
        curr_ids = layer_abs_ids(l) + (0:curr_size-1)';
        next_ids = layer_abs_ids(l+1) + (0:next_size-1)';
        
        for i = 1:curr_size
            if i == 1
                src(edge_count+1) = curr_ids(i);
                tgt(edge_count+1) = next_ids(1);
                edge_count = edge_count + 1;
            elseif i == curr_size
                src(edge_count+1) = curr_ids(i);
                tgt(edge_count+1) = next_ids(end);
                edge_count = edge_count + 1;
            else
                % 确保索引有效 (关键修复)
                j1 = min(i, next_size);
                j2 = max(1, min(i-1, next_size));
                src(edge_count + (1:2)) = curr_ids(i);
                tgt(edge_count + (1:2)) = [next_ids(j1); next_ids(j2)];
                edge_count = edge_count + 2;
            end
        end
    end

    % layerK → ender (修复：补充层节点k连接到ender层k-1和k)
    last_size = layer_sizes(end);
    last_ids = layer_abs_ids(end) + (0:last_size-1)';
    for i = 1:n
        % 关键修改：j1 = min(i, last_size) → 连接到ender i
        %           j2 = max(1, min(i-1, last_size)) → 连接到ender i-1
        if i == 1
            % i=1时，只能连接ender1（没有i-1=0）
            src(edge_count+1) = last_ids(1);
            tgt(edge_count+1) = ender_idxs(i);
            edge_count = edge_count + 1;
        elseif i == n
            % i=n时，连接补充层的第n-1和n个节点（确保连接到ender n-1和n）
            if last_size >= n
                % 连接补充层第n-1和n个节点（索引：n-1和n）
                src(edge_count + (1:2)) = [last_ids(n-1); last_ids(n)];
                tgt(edge_count + (1:2)) = ender_idxs(i);
                edge_count = edge_count + 2;
            else
                % 补充层节点数 < n，连接最后一个
                src(edge_count+1) = last_ids(last_size);
                tgt(edge_count+1) = ender_idxs(i);
                edge_count = edge_count + 1;
            end
        else
            % i=2到n-1：连接补充层第i-1和i个节点
            j1 = min(i, last_size);        % 补充层第i个节点
            j2 = max(1, min(i-1, last_size)); % 补充层第i-1个节点
            src(edge_count + (1:2)) = [last_ids(j2); last_ids(j1)];
            tgt(edge_count + (1:2)) = ender_idxs(i);
            edge_count = edge_count + 2;
        end
    end
else
    % 直连处理 (修复 |m-n|==1 的情况)
    if m == n
        for i = 1:m
            src(edge_count+1) = starter_idxs(i);
            tgt(edge_count+1) = ender_idxs(i);
            edge_count = edge_count + 1;
        end
    else
        % 仅连接数量少的点集
        min_size = min(m, n);
        for i = 1:min_size
            src(edge_count+1) = starter_idxs(i);
            tgt(edge_count+1) = ender_idxs(i);
            edge_count = edge_count + 1;
        end
    end
end

src = src(1:edge_count);
tgt = tgt(1:edge_count);

% ==============================
% Step 3: 位置优化 (关键修复：解决位置爆炸)
% ==============================
if total_insert > 0
    % 构建邻接表 (修复：避免ID映射错误)
    N = m + total_insert + n;
    adj = cell(N, 1);
    for i = 1:N
        adj{i} = [];
    end
    
    % 映射全局ID → 局部索引
    starter_local = 1:m;
    ender_local = m + total_insert + 1 : m + total_insert + n;
    insert_local = m + 1 : m + total_insert;
    
    % 添加边 (修复：使用局部索引)
    for e = 1:length(src)
        % starter → insert 或 ender
        if src(e) <= old_total_node_num
            if ismember(src(e), starter_idxs)
                u = find(starter_idxs == src(e), 1);
            else
                u = find(ender_idxs == src(e), 1) + m + total_insert;
            end
        else
            u = src(e) - old_total_node_num; % 全局ID → 局部ID
        end
        
        if tgt(e) <= old_total_node_num
            if ismember(tgt(e), starter_idxs)
                v = find(starter_idxs == tgt(e), 1);
            else
                v = find(ender_idxs == tgt(e), 1) + m + total_insert;
            end
        else
            v = tgt(e) - old_total_node_num;
        end
        
        % 添加无向边
        adj{u} = [adj{u}, v];
        adj{v} = [adj{v}, u];
    end
    
    % 初始化位置 (关键修复：避免数值爆炸)
    all_pos = [starter_poss; insert_nodes_pos; ender_poss];
    fixed_mask = [true(m,1); false(total_insert,1); true(n,1)];
    pos = all_pos;
    vel = zeros(N, 2);
    
    % 修复位置爆炸 (关键：调整刚度系数)
    k_spring = 0.001;    % 从 1.0 降至 0.001 (核心修复)
    damping = 0.9;       % 增加阻尼
    max_iter = 500;      % 增加迭代次数
    tol = 1e-5;          % 降低收敛阈值
    
    for iter = 1:max_iter
        force = zeros(N, 2);
        for i = 1:N
            if ~fixed_mask(i)
                for j = adj{i}
                    dx = pos(j,:) - pos(i,:);
                    dist = norm(dx);
                    % 修复：使用自然长度 (avg_node_dist)
                    f = k_spring * (dx / max(dist, 1e-6)) * (dist - avg_node_dist);
                    force(i,:) = force(i,:) + f;
                end
            end
        end
        
        vel = damping * vel + force;
        pos = pos + vel;
        
        % 收敛检查
        if norm(vel(~fixed_mask,:), 'fro') < tol
            break;
        end
    end
    
    insert_nodes_pos = pos(m+1 : m+total_insert, :);
end

end