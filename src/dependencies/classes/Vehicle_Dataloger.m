classdef Vehicle_Dataloger
    properties
        Ts
        time
        positions
        headings
        velocitys
        accelerations
        deltas
        laneNums
        lateral_error  
        idx
    end
    
    methods
        function obj = Vehicle_Dataloger(tspan,Ts)
            obj.Ts = Ts;
            obj.time = (tspan(1):Ts:tspan(2))';
            idx_max = length(obj.time);
            obj.positions = zeros(idx_max,2);
            obj.headings = zeros(idx_max,1);
            obj.velocitys = zeros(idx_max,1);
            obj.accelerations = zeros(idx_max,1);
            obj.deltas = zeros(idx_max,1);
            obj.lateral_error = zeros(idx_max,1);
            obj.idx = 0;
        end

        function obj = cutBeforeIdx(obj,idx)
            if nargin == 2
                obj.time(idx:end,:)=[];
                obj.positions(idx:end,:)=[];
                obj.headings(idx:end,:)=[];
                obj.velocitys(idx:end,:)=[];
                obj.accelerations(idx:end,:)=[];
                obj.deltas(idx:end,:)=[];
                obj.lateral_error(idx:end,:)=[];
            else
                idx = obj.idx+1;
                obj.time(idx:end,:)=[];
                obj.positions(idx:end,:)=[];
                obj.headings(idx:end,:)=[];
                obj.velocitys(idx:end,:)=[];
                obj.accelerations(idx:end,:)=[];
                obj.deltas(idx:end,:)=[];
                obj.lateral_error(idx:end,:)=[];
            end
        end
        function obj = logData(obj,vehicle)
            obj.idx = obj.idx + 1;
            if obj.idx ~=1
                obj.time(obj.idx,:) = obj.time(obj.idx-1,:)+obj.Ts;
            end
            obj.positions(obj.idx,:)=vehicle.pos;
            obj.headings(obj.idx,:)=vehicle.head;
            obj.velocitys(obj.idx,:)=vehicle.spd;
            obj.accelerations(obj.idx,:)=vehicle.acc;
            obj.deltas(obj.idx,:)=vehicle.delta;
            % obj.lateral_error(idx,:)=;
        end
        function showDatas(obj)
            

        end
    end
end