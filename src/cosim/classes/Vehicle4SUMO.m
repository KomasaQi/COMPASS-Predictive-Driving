classdef Vehicle4SUMO %#codegen
    properties
        id = 'undefined';      % 具体车型
        vClass = 'private';    % 车辆类型
        color = [0 1 1];       % 默认黄色
        accel = 1.0;           % 最大加速度
        decel = 2.0;           % 最小减速度
        sigma = 0.5;           % 不完美司机程度,0表示完美,[0 1]
        tau = 1.0;             % 期望车头时距 s
        lcAssertive = 1.0;     % 换道坚定程度
        lcKeepRight = 1.0;     % 向右换道的倾向
        lcOvertakeRight = 0.2; % 从右侧超车的可能
        lcSpeedGain = 100;     % 换道获取更高速度的动机
        lcSpeedGainRight = 0.5;    % 换道向右侧获取更高速度
        lcSpeedGainLookahead = 2;  % 
        lcSpeedGainRemainTime = 5; % 
        lcStrategic = 100;     % 战略换道意向系数 
        length = 5.5;          % 车辆长度 m 
        width = 1.8;           % 车辆宽度 m 
        maxSpeed = 33.3;       % 最大车速
        minGap = 6.5;          % 最小车间距（静止）
        speedFactor = [1 0.1 0.9 1.2]; % 速度系数：[均值 方差 下限 上限]（单位：1倍道路限速）
        
    end
    methods
        function obj = Vehicle4SUMO(varargin)
            for k = 1:2:length(varargin)
                if isprop(obj, varargin{k})
                    obj.(varargin{k}) = varargin{k+1};
                else
                    error('Property %s does not exist.', varargin{k});
                end
            end
        end


       
    end
end



