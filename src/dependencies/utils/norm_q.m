% 函数norm_q(data)，计算每一行的二范数
% 输入：data - n x m 矩阵，表示n个m维点
% 输出：v = n x 1 向量，表示每个点的norm
function v = norm_q(data)
    [n,m] = size(data);
    v = zeros(n,1);
    for i = 1:m
        v = v + data(:,i).^2;
    end
    v = sqrt(v);



end