function [delta_L, delta_R] = ackerman(wheelbase, track_width, steering_angle)
% ACKERMAN_STEERING 计算阿克曼转向的左右轮实际转角
%   [delta_L, delta_R] = ackerman_steering(wheelbase, track_width, steering_angle)
%   输入:
%       wheelbase: 轴距 (单位: 米)
%       track_width: 轮距 (单位: 米)
%       steering_angle: 名义转向角 (单位: 度)
%   输出:
%       delta_L: 左轮实际转角 (单位: 度)
%       delta_R: 右轮实际转角 (单位: 度)

    % 处理标量输入
    if isscalar(steering_angle)
        % 将转向角转换为弧度
        steering_rad = deg2rad(steering_angle);
        
        % 计算转弯半径
        if steering_rad == 0
            % 直行情况，两轮转角均为0
            delta_L = 0;
            delta_R = 0;
        else
            % 根据阿克曼原理计算转弯半径
            R = wheelbase / tan(steering_rad);
            
            % 计算左右轮的转弯半径
            R_L = R - track_width/2;
            R_R = R + track_width/2;
            
            % 计算左右轮的转角（弧度）
            delta_L_rad = atan(wheelbase / R_L);
            delta_R_rad = atan(wheelbase / R_R);
            
            % 将弧度转换为度
            delta_L = rad2deg(delta_L_rad);
            delta_R = rad2deg(delta_R_rad);
        end
        
    % 处理向量输入
    else
        n = length(steering_angle);
        delta_L = zeros(n,1);
        delta_R = zeros(n,1);
        
        % 对每个转向角进行计算
        for i = 1:n
            [delta_L(i), delta_R(i)] = ackerman(wheelbase, track_width, steering_angle(i));
        end
    end
end

% function [delta_L, delta_R] = ackerman(wheelbase, track_width, steering_angle)
% % ACKERMAN_STEERING 计算阿克曼转向的左右轮实际转角
% %   [delta_L, delta_R] = ackerman_steering(wheelbase, track_width, steering_angle)
% %   输入:
% %       wheelbase: 轴距 (单位: 米)
% %       track_width: 轮距 (单位: 米)
% %       steering_angle: 名义转向角 (单位: 度)
% %   输出:
% %       delta_L: 左轮实际转角 (单位: 度)
% %       delta_R: 右轮实际转角 (单位: 度)
%     if length(steering_angle) == 1
%         [delta_L, delta_R] = ackerman_steering(wheelbase, track_width, steering_angle);
%     else
%         delta_L = zeros(size(steering_angle));
%         delta_R = zeros(size(steering_angle));
%         for i = 1:length(steering_angle) 
%             [delta_L(i), delta_R(i)] = ackerman_steering(wheelbase, track_width, steering_angle(i));
%         end
%     end
% end
% 
% function [delta_L, delta_R] = ackerman_steering(wheelbase, track_width, steering_angle)
% % ACKERMAN_STEERING 计算阿克曼转向的左右轮实际转角
% %   [delta_L, delta_R] = ackerman_steering(wheelbase, track_width, steering_angle)
% %   输入:
% %       wheelbase: 轴距 (单位: 米)
% %       track_width: 轮距 (单位: 米)
% %       steering_angle: 名义转向角 (单位: 度)
% %   输出:
% %       delta_L: 左轮实际转角 (单位: 度)
% %       delta_R: 右轮实际转角 (单位: 度)
% 
%     % 将名义转向角转换为弧度
%     delta_rad = deg2rad(steering_angle);
% 
%     % 处理零转向角情况
%     if steering_angle == 0
%         delta_L = 0;
%         delta_R = 0;
%         return;
%     end
% 
%     % 计算转向半径R
%     R = wheelbase / tan(delta_rad);
% 
%     % 检查转向半径是否有效（|R| > track_width/2）
%     if abs(R) <= track_width / 2
%         % 转向半径过小，返回极限值（±90°）
%         sign_factor = sign(steering_angle);
%         delta_L = sign_factor * 90;
%         delta_R = sign_factor * 90;
%     else
%         % 计算左右轮实际转角（弧度）
%         delta_L_rad = atan(wheelbase / (R - sign(R) * track_width / 2));
%         delta_R_rad = atan(wheelbase / (R + sign(R) * track_width / 2));
% 
%         % 将弧度转换为度
%         delta_L = rad2deg(delta_L_rad);
%         delta_R = rad2deg(delta_R_rad);
%     end
%     delta_min = min([delta_L,delta_R]);
%     delta_max = max([delta_L,delta_R]);
%     delta_L = delta_max;
%     delta_R = delta_min;
% end
