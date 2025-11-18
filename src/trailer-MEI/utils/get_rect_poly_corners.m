function corners = get_rect_poly_corners(x, y, h, l, w)
    % 计算矩形车辆的四个角点（全局坐标）
    cos_h = cos(h);
    sin_h = sin(h);
    corners = zeros(5, 2);
    corners(1,:) = [x - l/2*cos_h - w/2*sin_h, y - l/2*sin_h + w/2*cos_h];
    corners(2,:) = [x + l/2*cos_h - w/2*sin_h, y + l/2*sin_h + w/2*cos_h];
    corners(3,:) = [x + l/2*cos_h + w/2*sin_h, y + l/2*sin_h - w/2*cos_h];
    corners(4,:) = [x - l/2*cos_h + w/2*sin_h, y - l/2*sin_h - w/2*cos_h];
    corners(5,:) = [x - l/2*cos_h - w/2*sin_h, y - l/2*sin_h + w/2*cos_h];
end
