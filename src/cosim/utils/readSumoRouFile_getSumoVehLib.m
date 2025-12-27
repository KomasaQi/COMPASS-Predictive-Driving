function [vehicle_library,route_dict] = readSumoRouFile_getSumoVehLib(file_path)
    theStruct = parseXML(file_path); % e.g. './data/test_cases/no1_4500_pass_1.rou.xml'
    vehicle_library = dictionary();
    route_info_dict = dictionary(string([]),{});
    route_dict = dictionary(string([]),{});

    for i = 1:length(theStruct.Children)
        if strcmpi(theStruct.Children(i).Name,'vType')
            theChild = theStruct.Children(i);
            theProps = cell(length(theChild.Attributes)*2,1);
            current_prop = 0;
            id = [];
            for j = 1:length(theChild.Attributes)
                attr = theChild.Attributes(j);
                current_prop = current_prop + 1;
                theProps{current_prop*2 - 1} = attr.Name;
                if (attr.Value(1) - '0') >= 0 && (attr.Value(1) - '0') <= 9
                    
                    theProps{current_prop*2} = str2double(attr.Value);
                elseif strcmpi(attr.Value(1),'#')
                    theProps{current_prop*2} = hex2rgb(attr.Value);
                elseif strcmpi(attr.Name,'speedFactor')
                    num_cell = strsplit(attr.Value(7:end-1), ','); 
                    num_array = str2double(num_cell);  
                    theProps{current_prop*2} = num_array;
                else
                    theProps{current_prop*2} = attr.Value;
                end
                if strcmpi(attr.Name,'id')
                    id = attr.Value;
                end
            end
            vehicle_library(id) = Vehicle4SUMO(theProps{:});
        end
        if strcmpi(theStruct.Children(i).Name,'route')
            theChild = theStruct.Children(i);
            id = getAttribute(theChild,'id');
            edges_str = getAttribute(theChild,'edges');
            edges = strsplit(edges_str, ' ', 'CollapseDelimiters', true);
            route_info_dict{id} = edges;
            
            
        end

    
    end
    for i = 1:length(theStruct.Children)
        if strcmpi(theStruct.Children(i).Name,'flow') || strcmpi(theStruct.Children(i).Name,'vehicle')
            theChild = theStruct.Children(i);
            id = getAttribute(theChild,'id');
            route_dict{id} = route_info_dict{getAttribute(theChild,'route')};
        end
    end
end

