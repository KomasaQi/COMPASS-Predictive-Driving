% 生成一条edge的有向图
% 生成思路: 
% STEP1:统计节点数量：首先我们统计一条edge上有多少个lane, 然后根据lane的数量, 我们找到平均的lane长度，
% 根据期望节点数量和最小节点数量确定纵向上有多少个节点。

% STEP2:生成多个车道子图：然后我们每一条lane生成一张图，图的节点数量为纵向节点数量乘以横向节点数量。
% 在一个lane的这张子图内部，我们纵向上基本上是每隔5m生成了一个节点，每个纵向节点横向上就会有3个节点，
% 分布在16.7% 50% 83.3% 车道宽度的位置。每个节点的命名规则是：laneID/纵向节点索引/横向节点索引 （从1开始），
% 如'402918900#3_0/4/3'表示纵向第4个节点，横向第3个节点（16%本车道的位置，是从左到右的顺序）。
% 节点之间的连接方式是：*/i/j连接*/i+1/j-1 & */i+1/j & */i+1/j+1，如果不存在其下一层的左/右节点，则不连接。

% STEP3:合并多个车道子图：最后我们将所有车道的子图合并起来，得到一条edge的有向图。一个Edge内部不同车道之间
% 的连接和车道内部相同，比如*_0/i/3连接（0号车道是左边的，所有edge都至少有0号车道，我们假设其有1号车道）
% *_1/i+1/1，然后*_1/i/1就也需要对称地连接*_0/i+1/3。最后我们返回一张有向的大图G_dir
% （上述所有连接都是从i向车道前进方向i+1的有向链接）

function G_edge = genEdgeGraph(edgeID,avg_node_dist,min_lane_long_node_num, lane_width_node_num, verbose, ego_dummy)
    global entity_dict connection_dict type_dict lane_to_connection_dict lane_from_connection_dict to_connection_dict %#ok
    global params %#ok
    if nargin < 2 || isempty(avg_node_dist)
        % avg_node_dist = 5.0; % 期望的平均节点距离
        avg_node_dist = params.graph.avg_node_dist;
    end
    if nargin < 3 || isempty(min_lane_long_node_num)
        min_lane_long_node_num = 3; % 一条lane上纵向最少的节点数量
    end
    if nargin < 4 || isempty(lane_width_node_num)
        lane_width_node_num = 3; % 一条lane上横向的节点数量
    end
    if nargin < 5 || isempty(verbose)
        verbose = false;
    end
    if nargin < 6 || isempty(ego_dummy)
        addRouteFeat = false;
    else
        addRouteFeat = true;
    end
    

    if isKey(entity_dict,edgeID)
        % STEP1: 统计节点数量
        laneNum = entity_dict{edgeID}.laneNum;
        laneGraphs = cell(laneNum,1);
        laneWidth = entity_dict{[edgeID '_0']}.width;
        laneLens = zeros(laneNum,1);
        % 首先统计edge的平均长度
        for i = 1:laneNum
            laneID = entity_dict{edgeID}.getLaneID(i-1);
            distance = xy2dist(entity_dict{laneID}.shape); 
            laneLens(i) = distance(end);
        end
        edgeLen = mean(laneLens);
        long_node_num = max(ceil(edgeLen/avg_node_dist),min_lane_long_node_num);
        
        % STEP2:每个车道生成一个子有向图s
        offset_dist = laneWidth/(lane_width_node_num);
        nodes_number_per_lane = long_node_num * lane_width_node_num; % 一条车道的lane数 
        inner_con_per_lane = (long_node_num - 1) * 7; 
        for i = 1:laneNum
            laneID = entity_dict{edgeID}.getLaneID(i-1);
            laneNo = i-1;
            lane_type = 'middle_lane';
            if laneNum == 1
                lane_type = 'single_lane';
            else
                if i == 1
                    lane_type = 'right_lane';
                elseif i == laneNum
                    lane_type = 'left_lane';
                end
                
            end
            laneGraphs{i} = genLaneGraph(laneID,long_node_num,offset_dist,verbose,lane_type,laneNo);
            
            
        end
        src = zeros(2*(long_node_num-1)*(laneNum-1) + inner_con_per_lane*laneNum, 1);
        tgt = zeros(2*(long_node_num-1)*(laneNum-1) + inner_con_per_lane*laneNum, 1);
        weights = zeros(2*(long_node_num-1)*(laneNum-1) + inner_con_per_lane*laneNum, 1);
        % nodes_pos = zeros(nodes_number_per_lane*laneNum,2);
        % nodes_type_feat = zeros(nodes_number_per_lane*laneNum,1);
        % free_ends_feat = zeros(nodes_number_per_lane*laneNum,1);
        nodeTables = cell(laneNum,1);
        for i = 1:laneNum
            % 节点特征收集
            % nodes_pos((i-1)*nodes_number_per_lane+(1:nodes_number_per_lane),:) = ...
            %     laneGraphs{i}.Nodes.nodes_pos;
            % nodes_type_feat((i-1)*nodes_number_per_lane+(1:nodes_number_per_lane),:) = ...
            %     laneGraphs{i}.Nodes.nodes_type_feat;
            % free_ends_feat((i-1)*nodes_number_per_lane+(1:nodes_number_per_lane),:) = ...
            %     laneGraphs{i}.Nodes.free_ends_feat;
            nodeTables{i} = laneGraphs{i}.Nodes;

            % 边特征收集
            src((i-1)*inner_con_per_lane+(1:inner_con_per_lane)) = ...
                laneGraphs{i}.Edges.EndNodes(:,1) + (i-1)*nodes_number_per_lane;
            tgt((i-1)*inner_con_per_lane+(1:inner_con_per_lane)) = ...
                laneGraphs{i}.Edges.EndNodes(:,2) + (i-1)*nodes_number_per_lane;
            weights((i-1)*inner_con_per_lane+(1:inner_con_per_lane)) = ...
                laneGraphs{i}.Edges.Weight;

        end
        % 添加lane与lane之间的额外连接
        for i = 1:laneNum-1
            src((laneNum*inner_con_per_lane)+(1:(long_node_num-1)*2)+(i-1)*(long_node_num-1)*2) = ...
                [...
                (long_node_num*2)+(1:long_node_num-1)+(i-1)*(long_node_num*3);...
                (1:long_node_num-1)+i*(long_node_num*3)...
                ];
            tgt((laneNum*inner_con_per_lane)+(1:(long_node_num-1)*2)+(i-1)*(long_node_num-1)*2) = ...
                [...
                (2:long_node_num)+i*(long_node_num*3);...
                (long_node_num*2)+(2:long_node_num)+(i-1)*(long_node_num*3)...
                ];
            weights((laneNum*inner_con_per_lane)+(1:(long_node_num-1)*2)+(i-1)*(long_node_num-1)*2) = ...
                [...
                params.graph.link_wight.side_left*ones(1,(long_node_num - 1));...
                params.graph.link_wight.side_right*ones(1,(long_node_num - 1))...
                ];
        end
        % weights((laneNum*inner_con_per_lane+1):end) = params.graph.link_wight.side;
        % nodetable = table(nodes_pos,nodes_type_feat,free_ends_feat);
        nodetable = vertcat(nodeTables{:});
        if addRouteFeat && ismember(edgeID,ego_dummy.route)
            nodetable.drivable = ones(size(nodetable.nodes_pos,1),1);
        else
            nodetable.drivable = zeros(size(nodetable.nodes_pos,1),1);
        end
        G_edge = digraph(src,tgt,weights,nodetable);

        if verbose
            % 用人类语言和漂亮的表格样式打印详细信息
 
        end

    else
        error('edgeID %s not found',edgeID)
    end
end

function G_lane = genLaneGraph(laneID,long_node_num,offset_dist,verbose,lane_type,laneNo)
    if nargin < 3 || isempty(offset_dist)
        offset_dist = 3.2/4;
    end
    if nargin < 4 || isempty(verbose)
        verbose = false;
    end
    global entity_dict type_dict params connection_dict %#ok
    % STEP2: 生成一个车道的子有向图
    % 首先统计该车道的长度
    distance = xy2dist(entity_dict{laneID}.shape); 
    laneLen = distance(end);
    interp_dist = linspace(0,laneLen,long_node_num)';
    center_nodes_pos = [
        interp1(distance,entity_dict{laneID}.shape(:,1),interp_dist), ...
        interp1(distance,entity_dict{laneID}.shape(:,2),interp_dist), ...
    ]; % 中心线节点的位置，也就是 */*/2的所有节点的位置
    dir_vec = center_nodes_pos(2,:) - center_nodes_pos(1,:);
    left_vec = rot2Dvec90deg(dir_vec,'left');
    right_vec = rot2Dvec90deg(dir_vec,'right');
    left_nodes_pos = offset2DCurve(center_nodes_pos,offset_dist,left_vec);
    right_nodes_pos = offset2DCurve(center_nodes_pos,offset_dist,right_vec);
    
    % 统计lane内总节点数量
    % nodes_number =  lane_width_node_num * long_node_num;
    % 生成节点位置属性
    nodes_pos = [right_nodes_pos;center_nodes_pos;left_nodes_pos]; % nodes_number x 2 (pos_x, pos_y)
    
    % 生成节点道路类型属性
    if strncmpi(lane_type,'single_lane',1)
        nodes_type_feat = [...
            params.graph.lane_feat.bound*ones(long_node_num,1);...
            params.graph.lane_feat.center*ones(long_node_num,1);...
            params.graph.lane_feat.bound*ones(long_node_num,1);...
            ];

    elseif strncmpi(lane_type,'middle_lane',1)
        nodes_type_feat = [...
            params.graph.lane_feat.right*ones(long_node_num,1);...
            params.graph.lane_feat.center*ones(long_node_num,1);...
            params.graph.lane_feat.left*ones(long_node_num,1);...
            ];

    elseif strncmpi(lane_type,'left_lane',1)
        nodes_type_feat = [...
            params.graph.lane_feat.right*ones(long_node_num,1);...
            params.graph.lane_feat.center*ones(long_node_num,1);...
            params.graph.lane_feat.bound*ones(long_node_num,1);...
            ];

    elseif strncmpi(lane_type,'right_lane',1)
        nodes_type_feat = [...
            params.graph.lane_feat.bound*ones(long_node_num,1);...
            params.graph.lane_feat.center*ones(long_node_num,1);...
            params.graph.lane_feat.left*ones(long_node_num,1);...
            ];

    else
        error('lane_type %s not found',lane_type);
    end
    
    % 创建辅助功能：车道自由起始点和自由终点标识
    free_ends_feat = zeros(long_node_num*3,1);
    free_ends_feat(1:long_node_num:(long_node_num*3)) = params.graph.marker.start; % 自由始点
    free_ends_feat((long_node_num):long_node_num:(long_node_num*3)) = params.graph.marker.end; % 自由终点

    % 创建道路类型特征
    edgeID = entity_dict{laneID}.getEdgeID();
    roadTypeID = entity_dict{edgeID}.type;
    % roadType = type_dict{roadTypeID};

    if strcmpi(roadTypeID,'highway.motorway')
        road_type_feat = params.graph.road_type_feat.highway_motorway;
        road_type = road_type_feat*ones(long_node_num*3,1);

    elseif strcmpi(roadTypeID,'highway.motorway_link')
        % 判断link是否是连接主路的
        link_mainRoad = false;
        if isKey(connection_dict,edgeID)
            connections = connection_dict{edgeID};
            for i = 1:connections.connection_num
                conn = connections.connections{i};
                if strcmpi(entity_dict{conn.to}.type,'highway.motorway')
                    link_mainRoad = true;
                    break
                end
            end
        end
        if link_mainRoad
            road_type = repmat(interp1(distance,distance/distance(end),interp_dist),[3,1]);
        else
            road_type = repmat(interp1(distance,1-distance/distance(end),interp_dist),[3,1]);
        end
        
    else
        road_type_feat = params.graph.road_type_feat.others;
        road_type = road_type_feat*ones(long_node_num*3,1);
    end
    
    
    % 创建限速特征
    lane_spd_lim = entity_dict{laneID}.speed;
    
    speed_lim = ones(long_node_num*3,1)*lane_spd_lim;

    % 创建车道编号特征
    lane_number = 1/3*[...
            -ones(long_node_num,1);...
            zeros(long_node_num,1);...
            ones(long_node_num,1);...
            ]+laneNo;

    

    % 创建车道子图并将上述特征赋予节点
    % 根据G_lane = digraph(src,tgt,wights,NodeTable)的方式来创建子图
    % 1.生成src和tgt, 1 x nodes_number的向量以及对应的边之间的weight(用节点之间的绝对距离算）
    next_links_src = 1:(long_node_num-1);
    next_links_tgt = 2:long_node_num;
    left_links_src = long_node_num + (1:(long_node_num-1));
    left_links_tgt = 2:long_node_num;
    right_links_src = 1:(long_node_num-1);
    right_links_tgt = long_node_num + (2:long_node_num);

    src = [ ...
           next_links_src,...
           next_links_src + long_node_num, ...
           next_links_src + long_node_num*2, ...
           left_links_src, ...
           left_links_src + long_node_num, ...
           right_links_src, ...
           right_links_src + long_node_num ...
           ];
    tgt = [ ...
           next_links_tgt,...
           next_links_tgt + long_node_num, ...
           next_links_tgt + long_node_num*2, ...
           left_links_tgt, ...
           left_links_tgt + long_node_num, ...
           right_links_tgt, ...
           right_links_tgt + long_node_num ...
           ];
    
    % 用绝对距离（平方）编码
    % wights = (nodes_pos(src,1) - nodes_pos(tgt,1)).^2 + (nodes_pos(src,2) - nodes_pos(tgt,2)).^2;
    % wights = (wights  - mean(wights))'; % 归一化

    % 直接用给定特征编码
    weights = [params.graph.link_wight.next*ones(1,(long_node_num - 1)*3), ...
              params.graph.link_wight.side_right*ones(1,(long_node_num - 1)*2), ...
              params.graph.link_wight.side_left*ones(1,(long_node_num - 1)*2)];

    % 2.创建NodeTable并创建图
    nodetable = table(nodes_pos,nodes_type_feat,free_ends_feat,lane_number,road_type,speed_lim);

    G_lane = digraph(src,tgt,weights,nodetable);
    if verbose
        % 用人类语言和漂亮的表格样式打印详细信息


    end
    
end

