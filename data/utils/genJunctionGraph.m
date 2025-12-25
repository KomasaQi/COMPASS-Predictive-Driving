function [src, tgt, weights,insertNodesTable] = genJunctionGraph(...
    starter_poss, ender_poss, starter_idxs, ender_idxs, old_total_node_num)
    global params %#ok
    
    % 计算开始点和结束点的数量
    start_pt_num = size(starter_poss,1);
    end_pt_num = size(ender_poss,1);

    % 分情况讨论
    %% starter数量和ender数量相同
    if start_pt_num == end_pt_num 
        min_dist = min(pdist2(starter_poss, ender_poss), [], 'all');
        insert_layer_num = round(min_dist/params.graph.avg_node_dist); % 插入节点层数
        insert_layer_size = start_pt_num; % 每层多少个
        link_number = (insert_layer_num + 1)*insert_layer_size + (insert_layer_num + 1)*(insert_layer_size - 2)*2;
        endNodes = zeros(link_number,2); % 初始化连接
        insert_nodes_num = insert_layer_num*insert_layer_size; % 真正插入的节点个数
        insert_layer_node_idxs = zeros(insert_layer_num+2,insert_layer_size); % 初始化存储层
        stored_node_num = 0; % 已经计算过数量的节点个数
        insert_layer_node_idxs(1,:) = starter_idxs';
        insert_layer_node_idxs(end,:) = ender_idxs';
        for i = 1:insert_layer_num
            theLayerNodeNum = insert_layer_size;
            insert_layer_node_idxs(i+1,:) = (1:theLayerNodeNum) + stored_node_num + old_total_node_num;
            stored_node_num = stored_node_num + theLayerNodeNum;
        end
        % ●--->●--->● 1
        %  ↘↗ ↘↗
        %  ↗↘ ↗↘
        % ●--->●--->● 2
        %  ↘↗ ↘↗
        %  ↗↘ ↗↘
        % ●--->●--->● 3
        %  ↘↗ ↘↗
        %  ↗↘ ↗↘
        % ●--->●--->● 4
        link_ptr = 1;
        for i = 0:insert_layer_num
            current_layer_idxs = insert_layer_node_idxs(i+1,:);
            next_layer_idxs = insert_layer_node_idxs(i+2,:);
            for j = 1:length(current_layer_idxs)
                endNodes(link_ptr,:) = [current_layer_idxs(j) next_layer_idxs(j)];
                link_ptr = link_ptr + 1;
            end
            for j = 2:length(current_layer_idxs)-1
                endNodes(link_ptr,:) = [current_layer_idxs(j) next_layer_idxs(j-1)];
                endNodes(link_ptr+1,:) = [current_layer_idxs(j) next_layer_idxs(j+1)];
                link_ptr = link_ptr + 2;
            end
        end



    %% starter数量和ender数量不同
    else 
        insert_layer_num = abs(start_pt_num - end_pt_num)-1; % 插入节点层数
        insert_layer_size = zeros(insert_layer_num+2,1);
        max_node_num = max(start_pt_num,end_pt_num);
        min_node_num = min(start_pt_num,end_pt_num);
        for i = 0:insert_layer_num + 1
            if start_pt_num > end_pt_num % 起始节点数量大于终止节点
                insert_layer_size(i+1) = max_node_num - i;
            else                         % 起始节点数量小于终止节点
                insert_layer_size(i+1) = min_node_num + i;
            end
        end
        link_number = (sum(insert_layer_size(2:end-1)) + min_node_num)*2;
        endNodes = zeros(link_number,2); % 初始化连接
        insert_nodes_num = sum(insert_layer_size(2:(end-1))); % 真正插入的节点个数
        insert_layer_node_idxs = cell(insert_layer_num+2,1); % 初始化存储层
        stored_node_num = 0; % 已经计算过数量的节点个数
        insert_layer_node_idxs{1} = starter_idxs';
        insert_layer_node_idxs{end} = ender_idxs';
        for i = 1:insert_layer_num
            if start_pt_num > end_pt_num % 起始节点数量大于终止节点
                theLayerNodeNum = (max_node_num - i);
                
            else                         % 起始节点数量小于终止节点
                theLayerNodeNum = (min_node_num + i); 
                
            end
            insert_layer_node_idxs{i+1} = (1:theLayerNodeNum) + stored_node_num + old_total_node_num;
            stored_node_num = stored_node_num + theLayerNodeNum;
        end

        

        if start_pt_num > end_pt_num % 起始节点数量大于终止节点
            % ●--->●--->● 1
            %    ↗   ↗
            %  ↗   ↗
            % ●--->●--->● 2
             %    ↗   ↗
            %  ↗   ↗ 
            % ●--->●      3
            %    ↗  
            %  ↗   
            % ●           4
            link_ptr = 1;
            for i = 0:insert_layer_num
                current_layer_idxs = insert_layer_node_idxs{i+1};
                next_layer_idxs = insert_layer_node_idxs{i+2};
                for j = 1:length(current_layer_idxs)-1
                    endNodes(link_ptr,:) = [current_layer_idxs(j) next_layer_idxs(j)];
                    link_ptr = link_ptr + 1;
                end
                for j = 2:length(current_layer_idxs)
                    endNodes(link_ptr,:) = [current_layer_idxs(j) next_layer_idxs(j-1)];
                    link_ptr = link_ptr + 1;
                end
            end

        else % 起始节点数量小于终止节点
            % ●--->●--->● 1
            %  ↘   ↘   
            %    ↘   ↘  
            % ●--->●--->● 2
            %  ↘   ↘   
            %    ↘   ↘  
            %      ●--->● 3
            %       ↘     
            %         ↘   
            %           ● 4

            link_ptr = 1;
            for i = 0:insert_layer_num
                current_layer_idxs = insert_layer_node_idxs{i+1};
                next_layer_idxs = insert_layer_node_idxs{i+2};
                for j = 1:length(current_layer_idxs)
                    endNodes(link_ptr,:) = [current_layer_idxs(j) next_layer_idxs(j)];
                    endNodes(link_ptr+1,:) = [current_layer_idxs(j) next_layer_idxs(j+1)];
                    link_ptr = link_ptr + 2;
                end
            end

        end

        
    end % 如果starter数量等于ender数量

    src = endNodes(:,1);
    tgt = endNodes(:,2);
    %% 利用弹性带方法计算中间插入节点的位置
    insert_nodes_pos0 = [ ...
        repmat(mean([starter_poss;ender_poss]),[insert_nodes_num,1]);...
        starter_poss;ender_poss];% 初始位置赋值
    update_mask = [ ...
        ones(insert_nodes_num,2);...
        zeros(size([starter_poss;ender_poss]))];% 位置更新mask
    
    projdict = dictionary([],[]);
    for i = 1:insert_nodes_num % 新添加节点的映射
        projdict(i + old_total_node_num) = i;
    end
    for i = 1:length(starter_idxs) % starter节点的映射
        projdict(starter_idxs(i)) = i + insert_nodes_num;
    end
    for i = 1:length(ender_idxs) % ender节点的映射
        projdict(ender_idxs(i)) = i + insert_nodes_num + length(starter_idxs);
    end
    % 计算每个节点的合力方向进行更新
    k = params.graph.slack.stiffness;
    repel = params.graph.slack.repel;
    pci = params.graph.slack.pure_contract_iter;
    lr = params.graph.slack.lr;
    cl = params.graph.slack.clip;
    tol = params.graph.slack.tol;
    early_stop = false;
    for iter = 1:params.graph.slack.max_iter
        force_vecs = zeros(size(insert_nodes_pos0));
        for i = 1:link_number
            n1 = projdict(endNodes(i,1));
            n2 = projdict(endNodes(i,2));
            pos1 = insert_nodes_pos0(n1,:);
            pos2 = insert_nodes_pos0(n2,:);
            vec12 = (pos2 - pos1) + randn(1,2)*1e-3;
            vec21 = -vec12;
            force_vecs(n1,:) = force_vecs(n1,:) + vec12*k + vec12.^11*k*0.01;
            force_vecs(n2,:) = force_vecs(n2,:) + vec21*k + vec21.^11*k*0.01;
        end
        % 加入节点斥力
        if iter > pci
            [min_dists, min_dist_idxs] = min(pdist2(insert_nodes_pos0,insert_nodes_pos0));
            for i = 1:insert_nodes_num
                n1 = i;
                n2 = min_dist_idxs(i);
                pos1 = insert_nodes_pos0(n1,:);
                pos2 = insert_nodes_pos0(n2,:);
                vec = (pos2 - pos1) + randn(1,2)*1e-3;
                d = min_dists(i) + 0.5;
                vec12 = vec/d;
                vec21 = -vec12;
                force_vecs(n1,:) = force_vecs(n1,:) + clip( 1/(d^2)*repel*vec21,-cl/2,cl/2);
                force_vecs(n2,:) = clip(force_vecs(n2,:) + 1/(d^2)*repel*vec12,-cl/2,cl/2);
            end
        end
        % 进行一步迭代更新位置
        d_node_pos = clip(force_vecs*lr,-cl,cl).*update_mask;
        insert_nodes_pos = insert_nodes_pos0 + d_node_pos;
        insert_nodes_pos0 = insert_nodes_pos;
        % 判断收敛与早停
        if max(abs(d_node_pos),[],"all") < tol 
            early_stop = true;
            disp(['因收敛条件满足，迭代停止于第'  num2str(iter) '步']);
            break
        end
        
        
    end
    if ~early_stop
        disp(['达到最大迭代次数'  num2str(iter) '步未收敛，迭代停止，当前位置误差为'  num2str(max(abs(d_node_pos),[],"all"))]);
    end
    nodes_pos = insert_nodes_pos(1:insert_nodes_num,:);
    weights = params.graph.link_wight.junction*ones(size(src,1),1);
    nodes_type_feat = params.graph.lane_feat.junction*ones(insert_nodes_num,1);
    free_ends_feat = zeros(insert_nodes_num,1);
    lane_number = zeros(insert_nodes_num,1);
    road_type = params.graph.road_type_feat.highway_motorway*ones(insert_nodes_num,1);
    speed_lim = params.graph.junction_speedlim*ones(insert_nodes_num,1);
    insertNodesTable = table(nodes_pos,nodes_type_feat,free_ends_feat,lane_number,road_type,speed_lim);
end