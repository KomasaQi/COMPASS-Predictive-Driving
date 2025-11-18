function radius = estimateCircleRadius(path)
    % 估计圆的半径：通过nx2的xy轨迹点拟合圆并计算半径
    % 输入：
    %   path - nx2的矩阵，每行表示一个(x,y)坐标点
    % 输出：
    %   radius - 估计的圆半径
    
    % 输入合法性检查
    if size(path, 2) ~= 2
        error('输入必须是nx2的矩阵（每行对应一个(x,y)点）');
    end
    n = size(path, 1);
    if n < 3
        error('至少需要3个点才能估计圆的参数');
    end
    
    % 提取x和y坐标
    x = path(:, 1);
    y = path(:, 2);
    
    % 构造线性方程组：x² + y² = A*x + B*y + C
    % 其中A=2a, B=2b, C=r² - a² - b²（(a,b)为圆心，r为半径）
    X = [x, y, ones(n, 1)];  % 设计矩阵
    Y = x.^2 + y.^2;         % 目标向量
    
    % 线性最小二乘求解A, B, C
    params = X \ Y;  % 求解最小二乘解，params = [A; B; C]
    A = params(1);
    B = params(2);
    C = params(3);
    
    % 计算圆心(a,b)和半径r
    a = A / 2;       % 圆心x坐标
    b = B / 2;       % 圆心y坐标
    radius = sqrt(a^2 + b^2 + C);  % 半径计算公式
end