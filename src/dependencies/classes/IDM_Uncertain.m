classdef IDM_Uncertain
%{
IDM驾驶员模型构建：自车加速度方程如下

a = a_max*(1-(v/v_des)^delta - (s_star(v,dv)/s)^2);

其中a_max为自车最大加速度，v为自车当前车速，v_des为自车的期望车速，delta为加速度指数其越大越激进
dv为自车和前车的车距，s_star(v,dv)为期望跟车间距
加速方程中分为两大部分，(v/v_des)^delta这部分衡量当前车速和期望车速的差，促进加速；
(s_star(v,dv)/s)^2这部分用来衡量当前车距和期望车距的差距，促进车辆制动。

s_star(v,dv) = s_min + max(0, v*T + (v*dv)/(2*sqrt(a_max*b)) )

其中b为舒适减速度。T为期望个车时距。期望车距方程有一个平衡项s_min+v*T，以及一个动力项
v*T + (v*dv)/(2*sqrt(a_max*b)) 来实现智能的刹车策略。
%}
    properties
        a_max % 最大加速度
        b     % 舒适减速度
        g     % 重力加速度
        mu   % 路面附着系数
        v_des % 期望车速
        delta % 加速度系数
        T     % 期望跟车时距
        s_min % 最小车间距（静止时）
        

        a_max_sigma % 上面各个参数的不确定度
        b_sigma
        v_des_sigma
        delta_sigma
        T_sigma
        s_min_sigma


        laneNum % 车道号
        
        ifrandom % 是否加入随机性

        ego_dist % 沿当前车道的行驶距离
        pv_dist  % 前车沿当前车道行驶距离
        cowardness % 胆怯系数
    end
   
    methods
        function obj = IDM_Uncertain(a_max,b,v_des,s_min,delta,T)
            if nargin < 1
                obj.a_max = 1;
                obj.b     = 2;
                obj.v_des = 30;
                obj.s_min = 3;
                obj.delta = 4;
                obj.T     = 1.6;%1.6
                
            else
                obj.a_max = a_max;
                obj.b     = b;
                obj.v_des = v_des;
                obj.s_min = s_min;
                obj.delta = delta;
                obj.T     = T;
            end
            obj.g = 9.806;
            obj.mu = 0.8*1;
            obj.cowardness = 1-1./(1+exp(obj.delta*0.7));

            obj.a_max_sigma = obj.a_max*0.2; % 上面各个参数的不确定度
            obj.b_sigma = obj.b*0.2;
            obj.v_des_sigma = obj.v_des*0.2;
            obj.delta_sigma = obj.delta*0.2;
            obj.T_sigma = obj.T*0.3;
            obj.s_min_sigma = obj.s_min*0.2;

            obj.a_max = max(0.5, obj.a_max + obj.a_max_sigma*randn());
            obj.b     = max(1.5, obj.b + obj.b_sigma*randn());
            obj.v_des = max(10, obj.v_des + obj.v_des_sigma*randn());
            obj.s_min = max(1, obj.s_min + obj.s_min_sigma*randn());
            obj.delta = max(1, obj.delta + obj.delta_sigma*randn());
            obj.T     = max(1, obj.T + obj.s_min_sigma*randn());

        end

        function s_star = get_s_star(obj,v_ego,v_p)
            dv = v_ego-v_p;
            s_star = obj.s_min + max(0, (v_ego*obj.T + (v_ego*dv/(2*sqrt(obj.a_max*obj.b)))));
        end
        function a = acc(obj,v_ego,v_p,s)
            a = obj.a_max*(1-(v_ego/obj.v_des)^obj.delta - (obj.get_s_star(v_ego,v_p)/s)^2);
            a_cons = obj.g*obj.mu;
            if a > a_cons
                a = a_cons;
            elseif a < -a_cons
                a = -a_cons;
            end
        end

    end

end

