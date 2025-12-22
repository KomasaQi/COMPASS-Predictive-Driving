function [starter_idxs, ender_idxs] = matchFreeEnds(start_poss, end_poss, proxy_dist)
% matchFreeEnds 找出 start_poss 和 end_poss 中彼此距离不超过 proxy_dist 的点
% 输入:
%   start_poss : m x 2 矩阵，起点坐标
%   end_poss   : n x 2 矩阵，终点坐标
%   proxy_dist : 标量，最大允许距离
% 输出:
%   starter_idxs : 被匹配的起点索引（列向量，去重）
%   ender_idxs   : 被匹配的终点索引（列向量，去重）
    if nargin < 3 || isempty(proxy_dist)
        proxy_dist = 50.0;
    end
    % 输入检查
    assert(size(start_poss, 2) == 2, 'start_poss must be m x 2');
    assert(size(end_poss, 2) == 2, 'end_poss must be n x 2');
    assert(isscalar(proxy_dist) && proxy_dist >= 0, 'proxy_dist must be non-negative scalar');

    m = size(start_poss, 1);
    n = size(end_poss, 1);

    if m == 0 || n == 0
        starter_idxs = [];
        ender_idxs = [];
        return;
    end

    % 计算所有点对之间的欧氏距离（使用 pdist2 或手动向量化）
    % 方法1：使用 pdist2（推荐，清晰）
    D = pdist2(start_poss, end_poss);  % m x n 距离矩阵

    % 找出所有距离 <= proxy_dist 的位置
    [i_match, j_match] = find(D <= proxy_dist);

    % 提取唯一索引（去重）
    ender_idxs = unique(i_match);
    starter_idxs = unique(j_match);
end