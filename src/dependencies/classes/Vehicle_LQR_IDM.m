classdef Vehicle_LQR_IDM
    properties
        % 命名参数
        car_id
        surr_veh_id % 周围车辆id 矩阵形式 2乘3，[l_p,c_p,r_p; l_f,c_f,r_f]; c表当前车道
        % 几何参数
        L
        W
        a
        b
        % 质量参数
        m
        Izz
        % 动力学参数
        tau_acc_dyn % 加速度响应时间常数
        tau_delta_dyn % 转向角响应时间常数
        % 轮胎参数
        k1
        k2
        % 状态参数
        pos   %[x,y]
        head  % 朝向角 rad
        spd   % 车速 m/s  
        acc   % 加速度 m/s2
        delta % 前轮转角 rad
        % 限制参数
        delta_max % 前轮转角限制 rad
        % 控制器
        latctrller
        longictrller
        % 规划器
        mobil
        planner
        Ts 
    end

    methods
        function obj = Vehicle_LQR_IDM(initpos,veh_params,ctrller_params,cons_params)
            obj.delta = initpos.delta;
            obj.pos = initpos.pos;
            obj.head = initpos.head;
            obj.spd = initpos.spd;
            obj.acc = initpos.acc;  
            obj.L = veh_params.L;
            obj.Ts = ctrller_params.Ts;
            obj.latctrller = LQR_TrackingController();
            obj.latctrller.Ts = obj.Ts;
            obj.latctrller.L = obj.L;
            obj.longictrller = IDM();
            obj.delta_max = cons_params.delta_max;
            obj.tau_acc_dyn = 0.35;
            obj.tau_delta_dyn = 0.05;
            obj.mobil = MOBIL(0.5,0.2,0); %p,delta_a,a_bias
        end

        function obj = step(obj,refpath,refspd,front_vehicle)
            ddelta=obj.latctrller.LQR_ctrl(obj.pos,obj.head,refpath,obj.spd,obj.delta);
            obj.longictrller.v_des = refspd(1);
            if isempty(front_vehicle)
                acc_des = obj.longictrller.acc(obj.spd,100,1000);
            else
                inter_veh_eql_dist = InterVehEqlDist(obj.pos,obj.head,obj.L,front_vehicle.pos,front_vehicle.L);
                acc_des = obj.longictrller.acc(obj.spd,front_vehicle.spd,inter_veh_eql_dist);
            end
            obj.acc = obj.acc + obj.Ts*(acc_des-obj.acc)/obj.tau_acc_dyn;
            %更新车辆状态
            delta_temp = ddelta + obj.delta;
            deltatt = obj.delta + obj.Ts*(delta_temp-obj.delta)/obj.tau_delta_dyn;
            obj.delta = sign(deltatt)*min([abs(deltatt),obj.delta_max]);
            obj.spd = obj.spd + obj.acc*obj.Ts;
            obj.pos=obj.pos+(obj.spd*obj.Ts).*[cos(obj.head),sin(obj.head)];
            obj.head=obj.head+obj.spd*obj.Ts*tan(obj.delta)/obj.L;
        end
        
        function acc = calcACC(obj,front_vehicle) % 假装这辆车是前车，用本车的IDM计算一下假定的加速度
            s = InterVehEqlDist(obj.pos,obj.head,obj.L,front_vehicle.pos,front_vehicle.L);
            acc = obj.longictrller.acc(obj.spd,front_vehicle.spd,s);
        end


    end

end