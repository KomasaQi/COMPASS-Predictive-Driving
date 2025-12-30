classdef Type_SUMO
    properties
        id = 'unclassified';
        priority = 4;
        speed_lim = [13.89 13.89 13.90]; % m/s private truck trailer

    end
    methods
        function obj = Type_SUMO(varargin)
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