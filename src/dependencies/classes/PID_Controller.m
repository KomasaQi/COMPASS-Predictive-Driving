%PID_CONTROLLER 离散PID控制器实现，支持高级控制功能
%
%   PID_Controller类实现了带有积分抗饱和、微分滤波和输出限幅功能的离散PID控制器。
%   支持属性-值对初始化，可通过step方法实时计算控制量。
%
% 属性 (可配置参数):
%   Kp - 比例增益 (默认: 1.0)
%   Ki - 积分增益 (默认: 0.0)
%   Kd - 微分增益 (默认: 0.0)
%   Ts - 采样时间(秒)，离散计算需要 (默认: 0.01)
%
%   output_upper_limit - 输出上限 (默认: inf)
%   output_lower_limit - 输出下限 (默认: -inf)
%   integral_upper_limit - 积分项上限 (默认: inf)
%   integral_lower_limit - 积分项下限 (默认: -inf)
%
%   derivative_filter_coeff - 微分滤波器系数 [0,1]
%       0: 无滤波，1: 完全滤波 (默认: 0.1)
%   anti_windup_method - 抗饱和方法:
%       'clamping'       - 积分箝位法 (默认)
%       'back-calculation'- 反算补偿法
%   back_calc_gain - 反算补偿增益 (默认: 1.0)
%
% 方法:
%   step(error) - 计算控制量
%       输入:  error - 当前时刻误差
%       输出:  u     - 计算得到的控制量
%
%   reset() - 重置控制器内部状态
%       清除积分项、微分滤波状态等历史信息
%
% 示例1: 基本使用
%   pid = PID_Controller('Kp',2.5, 'Ki',0.8, 'Ts',0.01);
%   for k = 1:1000
%       error = setpoint - measurement;
%       u = pid.step(error);
%       % 应用控制量到被控对象...
%   end
% 
% 基本使用（2）完全版
%     % 初始化PID控制器
%     pid = PID_Controller(...
%         'Kp', 2.5,...
%         'Ki', 1.2,...
%         'Kd', 0.05,...
%         'Ts', 0.01,...
%         'output_upper_limit', 10,...
%         'output_lower_limit', -10,...
%         'integral_upper_limit', 5,...
%         'anti_windup_method', 'back-calculation');
% 
%     % 仿真循环
%     for k = 1:1000
%         error = setpoint - actual_value;
%         control = pid.step(error);
%         % 应用控制量到被控对象...
%     end
% 
%     % 重置控制器状态
%     pid.reset();

%
% 示例2: 带抗饱和配置
%   pid = PID_Controller(...
%       'Kp', 1.2, ...
%       'output_upper_limit', 10, ...
%       'anti_windup_method', 'back-calculation', ...
%       'back_calc_gain', 0.5);
%
% 示例3: 运行时参数调整
%   pid.Kp = 3.0;        % 修改比例增益
%   pid.Ts = 0.02;       % 修改采样时间
%
% 注意事项:
%   1. 建议根据实际系统采样时间设置Ts参数
%   2. 输出限幅值应设为执行机构物理极限值
%   3. 长时间无误差时应调用reset()防止积分漂移
%   4. 微分滤波器系数推荐范围[0.05, 0.3]
%
% 参见: step, reset

classdef PID_Controller < handle
    properties
        % 基础PID参数
        Kp = 1.0;           % 比例增益
        Ki = 0.0;           % 积分增益
        Kd = 0.0;           % 微分增益
        Ts = 0.01;          % 采样时间(离散系统需要)
        
        % 限幅设置
        output_upper_limit = inf;   % 输出上限
        output_lower_limit = -inf;  % 输出下限
        integral_upper_limit = inf; % 积分项上限
        integral_lower_limit = -inf;% 积分项下限
        
        % 高级功能参数
        derivative_filter_coeff = 0.1; % 微分项滤波器系数(0-1)
        anti_windup_method = 'clamping'; % 抗饱和方法('clamping'|'back-calculation')
        back_calc_gain = 1.0;       % 反算抗饱和增益
        
        % 内部状态变量
        integral = 0;               % 积分项累积值
        last_error = 0;             % 上一时刻误差
        filtered_derivative = 0;    % 滤波后的微分项
        last_output = 0;            % 上次输出值(用于抗饱和)
    end
    
    methods
        function obj = PID_Controller(varargin)
            % 构造函数，支持属性-值对初始化
            for k = 1:2:length(varargin)
                if isprop(obj, varargin{k})
                    obj.(varargin{k}) = varargin{k+1};
                else
                    error('PID_Controller: invalid property %s', varargin{k});
                end
            end
            
            % 参数校验
            obj.validate_parameters();
        end
        
        function u = step(obj, error)
            % 计算比例项
            P = obj.Kp * error;
            
            % 计算积分项(带限幅)
            new_integral = obj.integral + obj.Ki * error * obj.Ts;
            new_integral = max(min(new_integral, obj.integral_upper_limit),...
                              obj.integral_lower_limit);
            
            % 计算微分项(带滤波)
            derivative = (error - obj.last_error) / obj.Ts;
            obj.filtered_derivative = obj.derivative_filter_coeff * derivative + ...
                (1 - obj.derivative_filter_coeff) * obj.filtered_derivative;
            D = obj.Kd * obj.filtered_derivative;
            
            % 计算原始输出
            raw_output = P + new_integral + D;
            
            % 输出限幅
            saturated_output = max(min(raw_output, obj.output_upper_limit),...
                                  obj.output_lower_limit);
            
            % 抗饱和处理
            switch obj.anti_windup_method
                case 'clamping'
                    if raw_output ~= saturated_output
                        new_integral = obj.integral; % 抑制积分累积
                    end
                    
                case 'back-calculation'
                    output_diff = saturated_output - raw_output;
                    new_integral = new_integral + obj.back_calc_gain * output_diff;
            end
            
            % 更新内部状态
            obj.integral = new_integral;
            obj.last_error = error;
            obj.last_output = saturated_output;
            
            u = saturated_output;
        end
        
        function reset(obj)
            % 重置控制器状态
            obj.integral = 0;
            obj.last_error = 0;
            obj.filtered_derivative = 0;
            obj.last_output = 0;
        end
        
        function validate_parameters(obj)
            % 参数校验
            assert(obj.Ts > 0, '采样时间必须大于0');
            assert(obj.derivative_filter_coeff >= 0 && ...
                obj.derivative_filter_coeff <= 1,...
                '微分滤波器系数必须在0-1之间');
            assert(ismember(obj.anti_windup_method, {'clamping','back-calculation'}),...
                '不支持的抗饱和方法');
        end
    end
end
