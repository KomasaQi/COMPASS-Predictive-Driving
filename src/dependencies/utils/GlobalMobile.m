%{
MOBIL模型 Kesting等人于2007年提出（最小化由换道行为引发的总体减速模型）
minimizing overall braking induced by lane changes
该模型用车辆加速度值表征驾驶者所得的驾驶利益，通过比较换道实施前后，当前车道与目标
车道上受影响车辆的整体利益变化来判断是否进行换道，并针对对称和非对称换道规则其除了相应的
换道模型。
MOBIL考察3辆车利益，本车，原车道后车，目标车道的新后车。换道需求建模：加速度
驾驶人对车道的选择本质上是看其在那条车道上能获得最大加速度。
另车辆ego选择第k条车道的效用值为U_ego_k,则有U_ego_k = a_ego_k
 
换道安全准则
目标车道后车加速度约束：间隙约束的间接描述
_hat表示换道后的值

(a_ego_hat - a_ego) + p*((a_hat_fhat - a_fhat)+(a_hat_f - a_f)) > delta_a + a_bias

p为礼让系数，p=0时只考虑自身利益，p=1时平等考虑自身和他人利益
detla_a为一个阈值，a_bias反应不对称换道情况。当交通规则倾向于驾驶人靠右侧车道行驶时
从左侧车道向右侧换道的门槛较低a_bias<0,反之a_bias>0。当左右换道具有同等权利时，a_bias=0

对于换道后新的跟随车辆，换道行为需要满足如下安全条件：
a_hat_fhat = f(v_fhat,v_ego,s_hat_fhat) > -b_safe
其中f是跟驰模型
%}
function vehicles = GlobalMobile(vehicles,jump_list,roadnet,specificVehicleNum)
     veh_Num = length(vehicles);
     TTC_min = 7; % TTC最小3s
     if nargin > 3 % 如果指定某车换道
         judging_list = specificVehicleNum;
     else
         judging_list = 1:veh_Num;
     end
     vis_scope = 90; % 关注范围为自车周围150m
     for carNum = judging_list% 为所有的车辆（除了jump_nums中的车辆）进行换道决策
        if max(ismember(jump_list,carNum)) % 如果这辆车在跳过名单中,跳过
            continue
        elseif vehicles{carNum}.planner.if_reach_goal % 对于到达终点的车也不必考虑
            continue
        end

        % 定位自车：
        [node1,node2,laneNum,~,~]=roadnet.locate(vehicles{carNum}.pos);
        surround_id = zeros(2,3);
        surr_veh_inteqldist = [1000*[1 1 1];-1000*[1 1 1]];
        valid_veh_list = zeros(veh_Num-1,1);
        valid_veh_num = 0;
        for i = 1:veh_Num  % 遍历每一辆车（除了自己），查找前车、后车
            if i == carNum % 如果是自己，跳过
                continue
            elseif vehicles{i}.planner.if_reach_goal % 已经抵达终点的车也不考虑
                continue
            end
            % step1:看是否是在附近150m内
            if norm(vehicles{carNum}.pos - vehicles{i}.pos)>vis_scope
                continue
            end
            valid_veh_num = valid_veh_num+1;
            valid_veh_list(valid_veh_num)=i;
        end
        valid_veh_list(valid_veh_num+1:end)=[];
        
        
        for side = -1:1 % 分别看一下左车道、本车道和右车道
            in_veh_eql_dist_min = 1000;
            in_veh_eql_dist_max = -1000;
            front_veh_num = 0;
            back_veh_num = 0;
            target_lane_id = laneNum + side;
            if target_lane_id < 1 || target_lane_id>length(vehicles{carNum}.planner.current_Road.lanes)
                continue
            end
            for i = valid_veh_list' % 对于每一辆非自己的在距离内的车进行判断
                % step3:计算车辆间距，并更新前方和后方最近的车辆id和距离
                dist = InterVehEqlDist(vehicles{carNum}.pos, vehicles{carNum}.head, vehicles{carNum}.L, vehicles{i}.pos, vehicles{i}.L);
                if ~(dist >= 0 && abs(dist)< vehicles{carNum}.longictrller.s_min*0.1)
                    % step2:看车辆是否在近本车道
                    [node1_veh,node2_veh,laneNum_veh,~,~]=roadnet.locate(vehicles{i}.pos);
                    if ~(min([node1_veh,node2_veh]==[node1,node2]) && (abs(laneNum_veh-target_lane_id)<2)) 
                        continue %只要不是路相同而且相差2个车道以内的，都跳过
                    end
                    [~,~,dev]=findTargetIdxDev(vehicles{i}.pos,vehicles{carNum}.planner.current_Road.lanes{target_lane_id}); 
                    if dev > 2.2 % 如果和当前车离得太远，也pass掉
                        continue
                    end
                end
                if dist >= 0 % 当是前车
                    if dist < in_veh_eql_dist_min
                        in_veh_eql_dist_min = dist;
                        front_veh_num = i;
                    end
                else  % 当是后车
                    if dist > in_veh_eql_dist_max
                        in_veh_eql_dist_max = dist;
                        back_veh_num = i;
                    end
                end   

            end
            % step4：修改车辆的周车id表
            surround_id(:,side+2)=[front_veh_num;back_veh_num]; 
            surr_veh_inteqldist(:,side+2)=[in_veh_eql_dist_min;in_veh_eql_dist_max];
        end
        vehicles{carNum}.planner.surr_veh_ids = surround_id;
        vehicles{carNum}.planner.surr_veh_inteqldist = surr_veh_inteqldist;

        if vehicles{carNum}.laneChangeTimer % 如果计时器不为0,不要换道
            continue
        elseif vehicles{carNum}.dist2End<50 % 距离停止线小于50m不允许换道
            % vehicles{carNum}.planner.target_lane_id = vehicles{carNum}.planner.current_lane_id; % 如果没有换道完成就别换了
            % vehicles{carNum}.laneChangeTimer = 0;
            continue 
        end
        
        current_lane_id = vehicles{carNum}.planner.current_lane_id;
        target_lane_decision = current_lane_id;
        left_flag = 0;
        right_flag = 0;
        % 计算不换道情况下的自车加速度
        if surround_id(1,2) == 0  % 如果当前没有前车
            a_ego = vehicles{carNum}.calcACC(); 
        else                                                % 如果当前有前车
            a_ego = vehicles{carNum}.calcACC(vehicles{surround_id(1,2)}); 
        end
        
        % 计算当前后车的加速度
        if surround_id(2,2) == 0 % 如果当前没有后车
            a_f = 0;
            a_hat_f = 0;
        else                                                           % 如果当前有后车
            a_f = vehicles{surround_id(2,2)}.calcACC(vehicles{carNum}); % 我就是后车的前车
            if surround_id(1,2) == 0                 % 我没有前车，所以换道以后后车也没有前车
                a_hat_f = vehicles{surround_id(2,2)}.calcACC();
            else  % 我有前车，我换道以后我的前车就是后车的前车
                a_hat_f = vehicles{surround_id(2,2)}.calcACC(vehicles{surround_id(1,2)});
            end 
        end
        
        %% 考虑后车的换道决策
        m = vehicles{carNum}.mobil;
        % 如果左换道
        % 先判断是否能左换道
        if current_lane_id ~= 1 % 只要不等于1就可以左换道
            % 计算自车换道后的加速度
            if surround_id(1,1) == 0  % 如果左车道没有前车
                a_ego_hat = vehicles{carNum}.calcACC(); 
            else                                                % 如果左车道有前车
                a_ego_hat = vehicles{carNum}.calcACC(vehicles{surround_id(1,1)}); 
            end
            % 计算左道后车换道前加速度
           
            if surround_id(2,1) == 0  % 如果左车道没有后车
                a_fhat = 0;
                a_hat_fhat = 0;
            else                      % 如果左车道有后车
                a_hat_fhat = vehicles{surround_id(2,1)}.calcACC(vehicles{carNum}); % 有后车，换道之后就是我
                if surround_id(1,1) == 0    % 如果左道没有有前车，那换道之前前车就是无，之后就是我
                    a_fhat = vehicles{surround_id(2,1)}.calcACC();
                else  %      左道前车，我换道以后我的前车就是后车的前车
                    a_fhat = vehicles{surround_id(2,1)}.calcACC(vehicles{surround_id(1,1)});
                end 
            end
            
            benefit_left = (a_ego_hat - a_ego) + m.p*((a_hat_fhat - a_fhat)+(a_hat_f - a_f));
            if benefit_left > (m.delta_a + m.a_bias(1))
                left_flag = 1;
            end
        end

        % 如果右换道
        if current_lane_id < length(vehicles{carNum}.planner.current_Road.lanes) % 只要不等于最右侧车道就可以右换道
            % 计算自车换道后的加速度
            if surround_id(1,3) == 0  % 如果右车道没有前车
                a_ego_hat = vehicles{carNum}.calcACC(); 
            else                                                % 如果右车道有前车
                a_ego_hat = vehicles{carNum}.calcACC(vehicles{surround_id(1,3)}); 
            end
            % 计算右道后车换道前加速度
           
            if surround_id(2,3) == 0  % 如果右车道没有后车
                a_fhat = 0;
                a_hat_fhat = 0;
            else                      % 如果右车道有后车
                a_hat_fhat = vehicles{surround_id(2,3)}.calcACC(vehicles{carNum}); % 有后车，换道之后就是我
                if surround_id(1,3) == 0    % 如果右道没有有前车，那换道之前前车就是无，之后就是我
                    a_fhat = vehicles{surround_id(2,3)}.calcACC();
                else  %      右道前车，我换道以后我的前车就是后车的前车
                    a_fhat = vehicles{surround_id(2,3)}.calcACC(vehicles{surround_id(1,3)});
                end 
            end
            
            benefit_right = (a_ego_hat - a_ego) + m.p*((a_hat_fhat - a_fhat)+(a_hat_f - a_f));
            if benefit_right > (m.delta_a + m.a_bias(2))
                right_flag = 1;
            end
        end
%% 最终换道决策
        % 判断一下如果左右换道，和后车的车距是否允许我这么做
        if left_flag && surround_id(2,1)~=0 % 如果想向左且左后方有车
            if -surr_veh_inteqldist(2,1)< vehicles{carNum}.longictrller.s_min*5
                left_flag = 0;
            end
            spd_diff = (vehicles{surround_id(2,1)}.spd - vehicles{carNum}.spd);
            if spd_diff <= 1e-3 % 如果后车速度比我小
                TTC_left = 1000;
            else
                TTC_left = -surr_veh_inteqldist(2,1)/spd_diff;
            end
            if TTC_left < TTC_min % 如果TTC太小，马上要碰撞
                left_flag = 0;
            end
        end
        if right_flag && surround_id(2,3)~=0 % 如果想向右且右后方有车
            if -surr_veh_inteqldist(2,3)< vehicles{carNum}.longictrller.s_min*5
                right_flag = 0;
            end
            spd_diff = (vehicles{surround_id(2,3)}.spd - vehicles{carNum}.spd);
            if spd_diff <= 1e-3 % 如果后车速度比我小
                TTC_right = 1000;
            else
                TTC_right = -surr_veh_inteqldist(2,3)/spd_diff;
            end
            if TTC_right < TTC_min % 如果TTC太小，马上要碰撞
                right_flag = 0;
            end
        end
        % 判断一下如果左右换道，和前车的车距是否允许我这么做
        if left_flag && surround_id(1,1)~=0 % 如果想向左且左前方有车
            if surr_veh_inteqldist(1,1)< vehicles{carNum}.longictrller.s_min*5
                left_flag = 0;
            end
            spd_diff = -(vehicles{surround_id(1,1)}.spd - vehicles{carNum}.spd);
            if spd_diff <= 1e-3 % 如果后车速度比我小
                TTC_left = 1000;
            else
                TTC_left = surr_veh_inteqldist(1,1)/spd_diff;
            end
            if TTC_left < TTC_min % 如果TTC太小，马上要碰撞
                left_flag = 0;
            end
        end
        if right_flag && surround_id(1,3)~=0 % 如果想向右且前方有车
            if surr_veh_inteqldist(1,3)< vehicles{carNum}.longictrller.s_min*5
                right_flag = 0;
            end
            spd_diff = -(vehicles{surround_id(1,3)}.spd - vehicles{carNum}.spd);
            if spd_diff <= 1e-3 % 如果后车速度比我小
                TTC_right = 1000;
            else
                TTC_right = surr_veh_inteqldist(2,3)/spd_diff;
            end
            if TTC_right < TTC_min % 如果TTC太小，马上要碰撞
                right_flag = 0;
            end
        end
        % 综合判断一下是否换道
        if left_flag && right_flag
            if benefit_left > benefit_right
                target_lane_decision = target_lane_decision - 1;
            else
                target_lane_decision = target_lane_decision + 1;
            end
        elseif left_flag && ~right_flag
            target_lane_decision = target_lane_decision - 1;
        elseif ~left_flag && right_flag
            target_lane_decision = target_lane_decision + 1;
        end
        vehicles{carNum}.planner.target_lane_id = target_lane_decision;
        % 重置换道决策计时器
        vehicles{carNum}.laneChangeTimer = vehicles{carNum}.laneChangeLimit;
     end
      

end
