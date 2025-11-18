function data_after = soft_add(original_data, added_value, soft_factor)
% SOFT_ADD 添加平滑过渡的偏移量
%   original_data: 原始数据向量 (1×N 或 N×1)
%   added_value: 要添加的常数值
%   soft_factor: 过渡区比例 (0~1)，值越大过渡区越长
%   data_after: 添加平滑偏移后的数据
if nargin < 3 || isempty(soft_factor)
    soft_factor = 0.1;
end 
n = numel(original_data);  % 获取数据长度
data_after = zeros(size(original_data));  % 初始化输出

% 计算过渡区长度 (至少2个点，不超过总长一半)
L = max(2, min(floor(n/2), round(n * soft_factor)));

% 生成五次多项式过渡曲线
t = linspace(0, 1, L)';
poly5 = 10*t.^3 - 15*t.^4 + 6*t.^5;  % 五次多项式曲线

% 构建完整的过渡曲线
transition = zeros(n, 1);
transition(1:L) = poly5;                  % 起始过渡区
transition(L+1:n-L) = 1;                  % 中间恒定区
transition(n-L+1:n) = 1 - poly5; % 结束过渡区 (反向)

% 应用过渡曲线并添加偏移
data_after(:) = original_data + added_value * transition;
end
