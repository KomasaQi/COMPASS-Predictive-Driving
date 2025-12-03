function rgb = hex2rgb(color_hex)
    % 功能：将#RRGGBB格式的颜色字符串转换为0~1的RGB数组
    % 输入：color_hex - 十六进制颜色字符串（如'#FFA500'、'#ffa500'）
    % 输出：rgb - 3元素数组，每个元素范围0~1（[R, G, B]）
    
    % 去除#前缀（若存在）
    if strcmp(color_hex(1), '#')
        color_hex = color_hex(2:end);
    end
    
    % 拆分并转换R/G/B
    r = hex2dec(color_hex(1:2)) / 255;
    g = hex2dec(color_hex(3:4)) / 255;
    b = hex2dec(color_hex(5:6)) / 255;
    
    rgb = [r, g, b];
end
% 
% % 调用示例
% rgb = hex2rgb('#FFA500');  % 输出：[1.0000, 0.6471, 0.0000]