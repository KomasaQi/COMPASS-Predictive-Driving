classdef Trajectory
    properties
        x
        y
        head
        time
    end
    methods
        function obj = Trajectory(x,y,time) % 初始化输入轨迹的x,y,time离散点，维度要相同
            obj.x = x;
            obj.y = y;
            obj.time = time;
            diff_x=diff(x);
            diff_y=diff(y);
            head0 = atan2(diff_y,diff_x);
            head0(end+1)=head0(end);
            obj.head = head0;
        end
        function [x,y,head] = getState(obj,time)
            x = interp1(obj.time,obj.x,time);
            y = interp1(obj.time,obj.y,time);
            head = interp1(obj.time,obj.head,time);
        end
    end
    
end
