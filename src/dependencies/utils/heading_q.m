function heading = heading_q(path)
    % 计算路径上每个点的航向角
    % 输入:
    %   path - n x 2的数组，表示路径点的坐标
    % 输出:
    %   heading - n x 1的数组，表示每个点的航向角（弧度）
    
    [n, ~] = size(path);
    heading = zeros(n, 1);
    
    % 对第一个点，使用前向差分
    if n > 1
        dx = path(2, 1) - path(1, 1);
        dy = path(2, 2) - path(1, 2);
        heading(1) = atan2(dy, dx);
    end
    
    % 对中间点，使用中心差分（更精确）
    for i = 2:n-1
        dx = path(i+1, 1) - path(i-1, 1);
        dy = path(i+1, 2) - path(i-1, 2);
        heading(i) = atan2(dy, dx);
    end
    
    % 对最后一个点，使用后向差分
    if n > 1
        dx = path(n, 1) - path(n-1, 1);
        dy = path(n, 2) - path(n-1, 2);
        heading(n) = atan2(dy, dx);
    end
end
