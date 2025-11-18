% 生成带噪声的圆轨迹点（圆心(2,3)，半径5）
theta = linspace(0, 2*pi*0.7, 100);  % 生成70%圆周的点
x = 2 + 5*cos(theta) + 0.2*randn(size(theta));  % 加噪声
y = 3 + 5*sin(theta) + 0.2*randn(size(theta));
path = [x', y'];  % 构造nx2的轨迹矩阵

% 估计半径
r_est = estimateCircleRadius(path);
fprintf('估计的半径为：%.4f\n', r_est);  % 应接近5
% 估计的半径为：5.0313