classdef Vehicle4Mei 
    properties
        x
        y
        v
        h
        l = 5
        w = 1.8
        has_trailer = false
        gamma
        lb = 1.5
        l_t = 11
        w_t = 2.5
    end
    methods
        function obj = Vehicle4Mei(varargin)
            for k = 1:2:length(varargin)
                if isprop(obj, varargin{k})
                    obj.(varargin{k}) = varargin{k+1};
                else
                    error('Property %s does not exist.', varargin{k});
                end
            end
            if ~isempty(obj.gamma)
                obj.has_trailer = true;
            end
        end

        function flag = is_semi_trailer(obj)
            flag = obj.has_trailer;
        end
    end
end