classdef vehicleShape
    properties
        body
        window
        parts
    end
    methods
        function obj = vehicleShape(Class)
            if strcmp(Class,'passenger_car')
                obj.body.x = [1 0.8 0.6 -0.75 -1 -1 -0.75 0.6 0.8 1]/2;
                obj.body.y = [0.6 0.9 1 1 0.7 -0.7 -1 -1 -0.9 -0.6]/2;
                obj.window{1}.x = [0.5 0.4 0.2 0.2 0.4 0.5]/2;
                obj.window{1}.y = [0.6 0.8 0.7 -0.7 -0.8 -0.6]/2;
                obj.window{2}.x = -1*([0.5 0.7 0.75 0.75 0.7 0.5]-0.1)/2;
                obj.window{2}.y = [0.7 0.8 0.6 -0.6 -0.8 -0.7]/2;
            elseif strcmp(Class,'bus')

            elseif strcmp(Class,'truck')

            elseif strcmp(Class,'semi_trailer_truck')
                
            else
                

            end
        end
    end

end