classdef RoadNetwork
    properties
        nodes    % 节点是一个1 x n的元组，表示了n个节点
        proxyMat % 节点之间的邻接矩阵，n × n,初始化为inf,表示每个节点之间的可能的连接
        Roads    % 元组，n x n 
    end

    methods
        function obj = RoadNetwork()
            obj.nodes = {};
            obj.Roads = {};
        end
        function obj = add_node(obj,node)
            previous_node_num = length(obj.nodes);
            obj.nodes{end+1} = node; % 添加路点
            obj.proxyMat(end+1,end+1)=0; % 设置邻接矩阵新行和列初值
            for i = 1:(previous_node_num)
                obj.proxyMat(end,i)=inf;
            end
            for i = 1:(previous_node_num)
                obj.proxyMat(i,end)=inf;
            end
            obj.Roads{end+1,end+1}=[]; % 初始化Roads的新行和列
        end

        function obj = add_connection(obj,node_num1,node_num2,Road)
            lane_num = length(Road.lanes);
            road_len = 0;
            for i = 1:length(Road.lanes)
                distances = xy2dist(Road.lanes{i});
                road_len = road_len + distances(end);
            end
            road_len = road_len/lane_num;
            obj.Roads{node_num1,node_num2}=Road;
            obj.proxyMat(node_num1,node_num2)=road_len;
        end
        %% Dijkstra算法，输入P为图的邻接矩阵，n x n
        % 输入起点和终点节点的代号数字
        % 返回最短距离
        function [distMin,route]=dijkstra(obj,idxStart,idxEnd)
            P = obj.proxyMat;
            juncNum=size(P,1);
            %起点和终点
            %% 创建辅助矩阵
            %储存完成识别最短路径的节点矩阵
            S=zeros(1,juncNum);
            %储存从起始点到其他点最短路径序列的数组
            Road=cell(1,juncNum);
            %% 迭代计算
            %第一步运算
            S(idxStart)=inf;%给对应节点编号位置赋值inf表示该节点已被计算
            U=P(idxStart,:);
            for i=1:juncNum
            Road{i}=idxStart;
            end
            for i=1:juncNum-1
                [~,idx]=min(S+U);%求出未计算最短点中最短路径的节点编号
                S(idx)=inf;
                [U,index]=min([U;U(idx)+P(idx,:)]); %更新最短距离
                UpdateSequ=find(index==2);
                for j=1:length(UpdateSequ) %更新最短路径序列
                    Road{UpdateSequ(j)}=[Road{idx},idx];
                end
            end
            for i=1:juncNum
                if i==idxStart
                    continue;
                end
                Road{i}=[Road{i},i];
            end
            %% 输出结果
            distMin=U(idxEnd);
            route=Road{idxEnd};
            disp(['从节点' num2str(idxStart) '到节点' num2str(idxEnd)...
                '的最短路程为' num2str(distMin) ',路径序列为：'...
                num2str(route)]);

        end
        function Road = createRoad(obj,node_1_num,node_2_num,middle_cv,laneNum,laneWidth)
             trunk_len = laneNum*laneWidth*1.5; % 裁剪的路段长度（为了防止多条路重叠）
             direction = obj.nodes{node_2_num} - obj.nodes{node_1_num};
             direction = [direction(2),-direction(1)]; % 向右旋转90°
             if size(middle_cv,1) == 1
                middle_cv = [middle_cv;middle_cv];
             end
             cv = [obj.nodes{node_1_num};
                       middle_cv;
                  obj.nodes{node_2_num}];
             Road = ROAD();
             path = Bspline(cv,[0 1],0.002,2,'noshowbase',4);%flag设置为2,使用非均匀B样条
             Road.center = path; % 道路中心
             distance = xy2dist(path);
             [~,idx1] = min(abs(distance-trunk_len));
             [~,idx2] = min(abs(distance-distance(end)+trunk_len));
             path = path(idx1:idx2,:);% 裁剪这部分内容
             Road.laneNum = laneNum;
             path = offset2DCurve(path,laneWidth*0.5,direction);
             Road.lanes{1} = path;
             if laneNum>1
                 for i = 2:laneNum
                     path = offset2DCurve(path,laneWidth,direction);
                     Road.lanes{i} = path;
                 end
             end
        end
        function [Road1,Road2]=create2WayRoad(obj,node_1_num,node_2_num,middle_cv,laneNum,laneWidth)
            Road1 = obj.createRoad(node_1_num,node_2_num,middle_cv,laneNum(1),laneWidth);
            Road2 = obj.createRoad(node_2_num,node_1_num,middle_cv(end:-1:1,:),laneNum(2),laneWidth);
        end
        function obj = add2WayRoad(obj,node1_num,node2_num,Road1,Road2)
            obj = obj.add_connection(node1_num,node2_num,Road1);
            obj = obj.add_connection(node2_num,node1_num,Road2);
        end
        function [current_node,target_node,laneNum,idx_min,P_min,dev_min] = locate(obj,pos)
            current_node = 0;
            target_node = 0;
            laneNum = 0;
            dev_min = inf;
            idx_min = 0;
            P_min = 0;
            for node1 = 1:length(obj.nodes)
                for node2 = 1:length(obj.nodes)
                    if node2 == node1
                        continue
                    end
                    if isempty(obj.Roads{node1,node2}) % 说明不存在这条路径
                        continue
                    end
                    for i = 1:length(obj.Roads{node1,node2}.lanes)
                        [p_min,idx,dev] = findTargetIdxDev(pos,obj.Roads{node1,node2}.lanes{i});
                        if norm(p_min - pos)> 1.75 % 与车道最近点距离超过3.5m,不算
                           continue
                        end
                        if dev < dev_min
                            dev_min = dev;
                            current_node = node1;
                            target_node = node2;
                            laneNum = i;
                            idx_min = idx;
                            P_min = p_min;
                            if dev_min < 1
                                break
                            end
                        end

                    end
                end
            end
    
        end

    end

end