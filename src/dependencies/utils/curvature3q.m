%% 【加速版】计算曲线的曲率、挠率
function [cur, tor] = curvature3q(path)
    % 计算一阶导
    delta = 1 / size(path,1);
    f1 = gradient(path, delta);
    % 计算二阶导
    f2 = gradient(f1, delta);
    % 计算三阶导
    f3 = gradient(f2, delta);
    % 计算曲率的分子
    v = cross(f1, f2); % 一阶导与二阶导做外积
    % 计算曲率的分母
    c = sqrt(sum(v.^2, 1)); % 一阶导二阶导外积的模长
    d = sqrt(sum(f1.^2, 1)); % 一阶导模长
    % 计算曲率和挠率
    cur = c ./ (d.^3); % 曲率
    tor = dot(f3, v, 1) ./ c.^2; % 挠率
end