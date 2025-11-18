classdef ROAD
    properties
        lanes
        laneNum
        spdlim  % 道路限速信息
        colorMap
        center
    end
    methods
        function obj = ROAD()
            obj.spdlim = 90/3.6;
            obj.colorMap = {"#0072BD",	"#D95319",	"#EDB120",	"#7E2F8E",	"#77AC30",	"#4DBEEE"};
        end
        function show(obj,fignum)
            if nargin < 2
                figure
            elseif fignum ~= -1
                figure(fignum)
            end
            hold on
            for i = 1:length(obj.lanes)
                plot(obj.lanes{i}(:,1),obj.lanes{i}(:,2),'Color',obj.colorMap{i})
            end
            hold off
            axis equal
        end
    end
end
