classdef SimplePlanner % 简单规划器，产生期望车速以及规划的path，这里的path包含了MOBIL产生的换道信息
    properties
        surr_veh_ids %周车ID矩阵形式 
        surr_veh_inteqldist % 矩阵形式 2乘3，[l_p,c_p,r_p; l_f,c_f,r_f]; c表当前车道
        current_lane_id  % 当前所在车道id
        target_lane_id   % 目标车道id
        destination_node % 全局目标节点
        current_node 
        target_node
        next_target_node
        current_Road
        Target_Road
        global_route
        plan_length_min
        plan_time_gain
        if_reach_goal
        roadnet
    end
     
    methods
        function obj = SimplePlanner(pos,planning_params)
            obj.roadnet = planning_params.roadnet;
            obj.current_node = planning_params.current_node;
            obj.destination_node = planning_params.destination_node;
            obj.if_reach_goal = false;
            [~, obj.global_route] = obj.roadnet.dijkstra(obj.current_node,obj.destination_node);
            if length(obj.global_route) > 1  % 获取目标节点、下一个目标节点
                obj.target_node = obj.global_route(2);
            else
                obj.target_node = obj.current_node;
                obj.if_reach_goal = true;
            end
            if length(obj.global_route) > 2
                obj.next_target_node = obj.global_route(3);
            else
                obj.next_target_node = obj.target_node;
            end
            obj.current_Road = obj.roadnet.Roads{obj.current_node,obj.target_node};
            obj.Target_Road =  obj.roadnet.Roads{obj.target_node,obj.next_target_node};
            % 通过计算和车道线中心的偏差确定一下是在当前道路的哪个车道上
            min_dev = inf;
            idx = 0;
            for i = 1:length(obj.current_Road.lanes)
                [~,~,dev]=findTargetIdxDev(pos,obj.current_Road.lanes{i});
                if dev < min_dev
                    min_dev = dev;
                    idx = i;
                end
            end
            obj.current_lane_id = idx;
            obj.target_lane_id = idx; % 初始化的时候暂且选择保持车道
            % 初始化周车id
            obj.surr_veh_ids = zeros(2,3);
            obj.surr_veh_inteqldist = 1000*[ones(1,3);-ones(1,3)];
            obj.plan_length_min = 10;
            obj.plan_time_gain = 0.8;
        end
        



        function flag = if_finishCurrentRoad(obj,pos)
            if ~obj.if_reach_goal
                current_road_end = obj.current_Road.lanes{obj.current_lane_id}(end,:);
                judge_limit = 5; % m 小于这个标准就算行驶到路尽头了
                flag = false;
                if norm(pos-current_road_end)<judge_limit
                    flag = true;
                end
            else
                flag = true;
            end
        end
        
        function obj = updateNodes(obj)
            if ~obj.if_reach_goal
                obj.global_route(1) = []; % 删除掉最初始的节点
                obj.current_Road = obj.Target_Road;
                if length(obj.global_route) > 1  % 获取目标节点、下一个目标节点
                    obj.target_node = obj.global_route(2);
                else
                    obj.target_node = obj.current_node;
                    obj.if_reach_goal = true;
                end
                if length(obj.global_route) > 2
                    obj.next_target_node = obj.global_route(3);
                else
                    obj.next_target_node = obj.target_node;
                end
                obj.Target_Road = obj.roadnet.Roads{obj.target_node,obj.next_target_node};
            end
        end


        function path = plan(obj,pos,head,spd,iscruising)
            if ~obj.if_reach_goal
                plan_dist = obj.plan_length_min + obj.plan_time_gain*spd;
                target_lane = obj.current_Road.lanes{obj.target_lane_id};
                % 找到当前位置的distance
                idx_0=findTargetIdx(pos,target_lane);  
                distance = xy2dist(target_lane);
                [~,idx] = min(abs(distance - distance(idx_0)-plan_dist));
                if iscruising && idx_0 > 1
                    if idx_0 >= (size(target_lane,1)-3)
                        idx_0 = idx_0-1;
                    end
                    vec = target_lane(idx_0+1,:)-target_lane(idx_0,:);
                    [road_head,~] = cart2pol(vec(1),vec(2));
                    state = [target_lane(idx_0,:) road_head];
                    % state = [pos head];
                else
                    state = [pos head];
                end
                if idx >= size(target_lane,1)
                    idx = idx-1;
                end
                idx_next = idx+1;
                path_pos = target_lane(idx,:);
                vec = target_lane(idx_next,:)-path_pos;
                
                
                % 进行判断是否是驶入路口前
                vec1 = path_pos - pos; % 自车指向规划终点
                vec1 = vec1/norm(vec1);% 单位向量化
                vec2 = target_lane(1,:) - pos; % 自车指向
                proj_len = dot(vec1,vec2);
                
                if proj_len > 2 && norm(vec2) < 40 && norm(vec2) > plan_dist*0.6 % 投影>2m并且我和道路起点<40m
                    vec = target_lane(2,:)-target_lane(1,:);
                    [path_head,~] = cart2pol(vec(1),vec(2));
                    [path,~,~]=bsplinepath_xyth(state,[target_lane(1,:),path_head],[0,1],0.01);
                else
                    [path_head,~] = cart2pol(vec(1),vec(2));
                    [path,~,~]=bsplinepath_xyth(state,[path_pos,path_head],[0,1],0.01);
                end
            else
                [path,~,~]=bsplinepath_xyth([pos,head],[pos+0.1*obj.plan_length_min*[cos(head),sin(head)],head],[0,1],0.1);
            end
        end


    end
end