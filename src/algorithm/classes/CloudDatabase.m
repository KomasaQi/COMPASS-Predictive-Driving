classdef CloudDatabase 
    properties
        % 车辆几何参数

        
    end
    methods
        function obj = CloudDatabase(varargin)
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



