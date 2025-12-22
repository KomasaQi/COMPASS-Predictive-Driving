function sorted_idxs = sortVector(vecs)
% sortVector 对近似共线（或轻微折线）的二维点进行排序
%
% 输入：
%   vecs : n×2 的矩阵，每一行是一个 [x, y] 坐标点
%
% 输出：
%   sorted_idxs : n×1 的列向量，表示对原始点的索引重排顺序，
%                 使得按此顺序连接所有点时路径总长度近似最短，
%                 并且在正向/反向两种最优方向中，选择与原始索引顺序
%                 [1,2,...,n] 改动最小的一种。
%
% 适用场景：
%   点大致沿一条直线或平缓折线分布（如轨迹、扫描线、边缘轮廓等）
%
% 方法概述：
%   1. 使用主成分分析（PCA）找出点云的主方向；
%   2. 将所有点投影到该主方向上，得到一维坐标；
%   3. 按投影值排序，得到一个候选顺序；
%   4. 考虑正向和反向两种路径；
%   5. 选择与原始索引顺序 [1,2,...,n] 更接近（改动更小）的那个方向。
%
% 注意：
%   - MATLAB 中索引从 1 开始，因此原始顺序为 (1:n)'
%   - “改动最小”定义为：排序后索引序列与 (1:n)' 的绝对位移之和最小

    % 检查输入维度
    [n, d] = size(vecs);
    if d ~= 2
        error('输入必须是 n×2 的二维点集！');
    end

    % 特殊情况处理：点数 ≤ 2
    if n <= 1
        sorted_idxs = (1:n)';
        return;
    elseif n == 2
        % 两个点只有一种无向连接，但有两种方向。
        % 为最小化对原始顺序的改动，直接返回 [1; 2]
        sorted_idxs = (1:2)';
        return;
    end

    % 第一步：计算点云的质心（均值）
    centroid = mean(vecs, 1);  % 1×2 向量

    % 第二步：去中心化（将坐标原点移到质心）
    centered = vecs - centroid;  % n×2 矩阵

    % 第三步：通过 SVD（奇异值分解）进行 PCA，获取主方向
    % 对 centered 矩阵做 SVD：centered = U * S * V'
    % V 的列是主成分方向，第一列对应最大方差方向（主轴）
    [~, ~, V] = svd(centered, 'econ');  % 'econ' 表示经济型分解，节省内存
    main_dir = V(:, 1);  % 主方向向量（2×1）

    % 第四步：将每个点投影到主方向上，得到一维标量
    % 投影值 = 点 · 主方向（因为主方向是单位向量）
    projections = centered * main_dir;  % n×1 列向量

    % 第五步：根据投影值对点进行排序，得到索引顺序
    % [~, sorted_order] = sort(projections) 返回升序排列对应的原始索引
    [~, sorted_order] = sort(projections);  % sorted_order 是 n×1 列向量

    % 第六步：生成两个候选路径（正向 和 反向）
    forward_path  = sorted_order;           % 沿主方向从小到大
    backward_path = flipud(sorted_order);   % 沿主方向从大到小

    % 第七步：定义“改动程度”的度量标准
    % 原始索引顺序为 [1; 2; 3; ...; n]
    original_order = (1:n)';

    % 计算每个候选路径与原始顺序的“绝对位移和”
    % 即 sum(|candidate(i) - i|)，i 从 1 到 n
    cost_forward  = sum(abs(forward_path  - original_order));
    cost_backward = sum(abs(backward_path - original_order));

    % 第八步：选择改动更小的方向作为最终结果
    if cost_forward <= cost_backward
        sorted_idxs = forward_path;
    else
        sorted_idxs = backward_path;
    end

end