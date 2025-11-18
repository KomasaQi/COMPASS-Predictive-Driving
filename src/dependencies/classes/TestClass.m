classdef TestClass
    properties
        
    end
    methods
        function obj=TestClass()
            
        end
        function a = acc(obj)
            global idm_model
            a = idm_model.acc(10,10,15);

        end
    end
end 