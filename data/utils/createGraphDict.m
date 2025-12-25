% 生成单个edge的graph的字典，只包含非路口内的edge
function graph_dict = createGraphDict(verbose)
    if nargin < 1
        verbose = false;
    end
    global entity_dict params %#ok
    graph_dict = dictionary(string([]),{}); % 生成一个空字典，从edgeID映射到一个有向图
    keys = entity_dict.keys;
    processed_num = 0;
    for i = 1:length(keys)
        key = keys{i};
        entity = entity_dict{key};
        if isa(entity,'Edge_SUMO')
            if ~strncmp(key,':',1) % 只存储非路口内的边的graph
                processed_num = processed_num + 1;
                if verbose
                    fprintf('正在处理第%d条edge %s\n',processed_num,key);
                end
                graph_dict{key} = genEdgeGraph(key);
            end
        end
        
    end
    if verbose 
        fprintf('处理完成！共处理%d条edge\n',processed_num);
    end

end