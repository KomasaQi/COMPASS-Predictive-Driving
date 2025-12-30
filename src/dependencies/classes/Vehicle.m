classdef Vehicle
    properties
        % 命名参数
        car_id
        Class % 有'passenger_car','bus','truck','semi_trailer_truck'等等
        surr_veh_id % 周围车辆id 矩阵形式 2乘3，[l_p,c_p,r_p; l_f,c_f,r_f]; c表当前车道
        % 几何参数
        L
        W
        L_ab
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
        iscolide % 是否碰撞
        dist2End % 到达停止线的距离
        iscruising % 是否在巡航（换道时就是非巡航状态）
        isInInterSection % 是否在交叉路口
        % 限制参数
        delta_max % 前轮转角限制 rad
        delta_max_current % 控制过程中使用的实时前轮转角限制
        % 控制器
        latctrller
        longictrller
        % 规划器
        mobil
        planner
        Ts 
        refpath
        % 形状参数（用于绘图）
        shape
        color_randnoise
        % 换道计时器
        laneChangeTimer
        laneChangeLimit
        % 特殊车辆标记
        iscrazy
        % 车辆图像
        car_img
        img_alpha
        car_shade
        shade_alpha
        % 轨迹播放功能相关
        trajectory
    end

    methods
        function obj = Vehicle(initpos,veh_params,ctrller_params,cons_params,mobil_params,planning_params)
            obj.delta = initpos.delta;
            obj.pos = initpos.pos;
            obj.head = initpos.head;
            obj.spd = initpos.spd;
            obj.acc = initpos.acc;  
            obj.L = veh_params.L;
            obj.W = veh_params.W;
            obj.L_ab = veh_params.L_ab;
            obj.Class = veh_params.Class;
            obj.Ts = ctrller_params.Ts;
            obj.latctrller = LQR_TrackingController();
            obj.latctrller.Ts = obj.Ts;
            obj.latctrller.L = obj.L_ab;
            obj.longictrller = IDM();
            obj.delta_max = cons_params.delta_max;
            obj.tau_acc_dyn = 0.35;
            obj.tau_delta_dyn = 0.05;%0.05
            obj.mobil = MOBIL(mobil_params.p,mobil_params.delta_a,mobil_params.a_bias); %p,delta_a,a_bias
            obj.planner = SimplePlanner(obj.pos,planning_params);
            obj.shape = vehicleShape(obj.Class);
            obj.color_randnoise = 0.1*randn(1,3);
            obj.laneChangeLimit = 0.2+2*rand(1); % 0.2秒内不许改变换道决策；
            obj.laneChangeTimer=0;
            obj.dist2End = obj.calcDist2End();
            obj.iscruising = 0;
            obj.iscrazy = 0;
            obj.isInInterSection = 0;
            [car_img,~,obj.img_alpha] = imread('YellowVeh.png');
            hue_shift = rand(1)-0.5; % 色相偏移值
            hsv_img = rgb2hsv(car_img); % 将 RGB 图像转换为 HSV 颜色空间
            hsv_img(:, :, 1) = mod(hsv_img(:, :, 1) + hue_shift, 1); % 调整色相通道
            modified_img = hsv2rgb(hsv_img); % 将修改后的 HSV 图像转换回 RGB 格式
            deviation = rand(3,1)*1-0.6;
            purify = (rand(1)>0.3);
            obj.car_img = obj.var_imgColor(modified_img,deviation,purify);
            [obj.car_shade,~,obj.shade_alpha] = imread('YellowVeh_Shade.png');

        end
        %% 子函数： 步进更新车辆状态
        function obj = step(obj,front_vehicle) % 当不存在前车时输入[]即可
            % 进行换道决策
            %   这里要调用全局的MOBIL函数
            % 进行轨迹规划
            obj.refpath = obj.planner.plan(obj.pos,obj.head,obj.spd,obj.iscruising);
            % 更新规划器里的状态
            [~,~,laneNum,~,~,dev]=obj.planner.roadnet.locate(obj.pos);
            if laneNum ~= 0
                obj.planner.current_lane_id = laneNum;
            end

            obj.dist2End = obj.calcDist2End();
            if obj.planner.if_finishCurrentRoad(obj.pos)
                obj.planner = obj.planner.updateNodes();
                obj.planner.current_lane_id = laneNum;
                refspd = 0;
            elseif obj.dist2End<100 % 距离停止线小于50m,车速降低
                refspd = obj.planner.current_Road.spdlim * obj.longictrller.cowardness*(1-1./(1+exp(0.05*obj.dist2End-1)));
                refspd = refspd + 1*randn(1);
            else
                refspd = obj.planner.current_Road.spdlim * obj.longictrller.cowardness;
                refspd = refspd + 1*randn(1);
            end
            if obj.iscrazy
                refspd = 1.2*refspd;
            end

            % 更新换道计时器状态
            obj.laneChangeTimer = max(obj.laneChangeTimer - obj.Ts,0);
            % 更新更新是否完成换道/是否巡航的状态
            if obj.planner.target_lane_id == obj.planner.current_lane_id && dev < 0.5
                obj.iscruising = 1;
            else
                obj.iscruising = 0;
            end

            % 进行轨迹跟踪控制和车速控制
            ddelta=obj.latctrller.LQR_ctrl(obj.pos,obj.head,obj.refpath,obj.spd,obj.delta);
            obj.longictrller.v_des = refspd(1);
            if isempty(front_vehicle)
                acc_des = obj.longictrller.acc(obj.spd,100,1000);
            else
                inter_veh_eql_dist = InterVehEqlDist(obj.pos,obj.head,obj.L,front_vehicle.pos,front_vehicle.L);
                acc_des = obj.longictrller.acc(obj.spd,front_vehicle.spd,inter_veh_eql_dist);
            end
            obj.acc = obj.acc + obj.Ts*(acc_des-obj.acc)/obj.tau_acc_dyn;
            
            % 更新前轮转角限制
            obj.delta_max_current = obj.calcRealTimeDeltaMax();

            % 更新车辆状态
            if obj.planner.if_reach_goal 
                obj.delta = 0;
                obj.spd = 0;
            else
                delta_temp = ddelta + obj.delta;
                deltatt = obj.delta + obj.Ts*(delta_temp-obj.delta)/obj.tau_delta_dyn;
                obj.delta = sign(deltatt)*min([abs(deltatt),obj.delta_max_current]);
                obj.spd = max(obj.spd + obj.acc*obj.Ts,0);
                obj.pos=obj.pos+(obj.spd*obj.Ts).*[cos(obj.head),sin(obj.head)];
                obj.head=obj.head+obj.spd*obj.Ts*tan(obj.delta)/obj.L;
            end
        end
        %% 子函数： 用指定轨迹更新状态
        function obj = stepWithTraj(obj,time)
            [x,y,head0] = obj.trajectory.getState(time);
            obj.pos = [x,y];
            obj.head = head0;
        end

        %% 子函数： 给定假想前车用IDM计算本车加速度
        function acc = calcACC(obj,front_vehicle) % 假装这辆车是前车，用本车的IDM计算一下假定的加速度
            if nargin < 2
                acc = obj.longictrller.acc(obj.spd,100,1000);
            else
                s = InterVehEqlDist(obj.pos,obj.head,obj.L,front_vehicle.pos,front_vehicle.L);
                acc = obj.longictrller.acc(obj.spd,front_vehicle.spd,s);
            end
        end

        %% 子函数： 绘制本车图形
        function handle = show(obj,Color) % color可用'r','b'等也可用[0,118,58]/255这种RGB表示
            handle{3} = [];
            [xcar,ycar]=obj.RotatePolygon(obj.pos(1)+obj.shape.body.x*obj.L,obj.pos(2)+obj.shape.body.y*obj.W,obj.pos,obj.head);
            if nargin < 2  
                handle{1} = fill(xcar,ycar,'y','EdgeColor','none'); 
            else
                handle{1} = fill(xcar,ycar,max(min(Color+obj.color_randnoise,[1 1 1]),[0,0,0]),'EdgeColor','none'); 
            end
            for i = 1:length(obj.shape.window)
                [xwin,ywin]=obj.RotatePolygon(obj.pos(1)+obj.shape.window{i}.x*obj.L,obj.pos(2)+obj.shape.window{i}.y*obj.W,obj.pos,obj.head);
                handle{i+1} = fill(xwin,ywin,max(min([0 0.2470 0.5410]+obj.color_randnoise,[1 1 1]),[0,0,0]),'EdgeColor','none'); 
            end
        end

        %% 子函数： 绘出车辆图像
        function handle = showImg(obj,light_angle,time)
            if nargin < 3 
                x = obj.pos(1);
                y = obj.pos(2);
                head0 = obj.head;
            else
                if isempty(obj.trajectory)
                    disp('当前车辆还没有轨迹！请赋值！格式：vehicle.trajectory = Trajectory(x,y,time)');
                else
                    [x,y,head0] = obj.trajectory.getState(time);
                end
            end
            rot_angle = (-head0/pi-0.5)*180;
            if nargin < 2 || isempty(light_angle)
                light_angle = 45;
            end
            shade_deviation = [0.5,0];
            angle_rad = deg2rad(light_angle);% 将角度转换为弧度    
            R = [cos(angle_rad), -sin(angle_rad); sin(angle_rad), cos(angle_rad)];% 构造旋转矩阵
            shade_vec = shade_deviation * R;% 进行向量旋转
            handle{1} = imagesc('XData', [-1,1]*obj.L/2+x+shade_vec(1), 'YData', [-1,1]*obj.L/2+y+shade_vec(2), 'CData', imrotate(obj.car_shade,rot_angle),'AlphaData',imrotate(obj.shade_alpha,rot_angle));
            handle{2} = imagesc('XData', [-1,1]*obj.L/2+x, 'YData', [-1,1]*obj.L/2+y, 'CData', imrotate(obj.car_img,rot_angle),'AlphaData',imrotate(obj.img_alpha,rot_angle));

        end

        %% 子函数： 旋转多边形
        function [x1,y1]=RotatePolygon(~,x,y,center,th)
            pointNum=length(x);
            x1=zeros(size(x));
            y1=zeros(size(y));
            for i=1:pointNum
                xc=x(i)-center(1);
                yc=y(i)-center(2);
                x1(i)=(xc*cos(th)-yc*sin(th))+center(1);
                y1(i)=(xc*sin(th)+yc*cos(th))+center(2);
            end
        end

        %% 子函数： 更新当前最大转角
        function delta_max_current = calcRealTimeDeltaMax(obj)
            delta_min = 5/180*pi;
            k = obj.delta_max-delta_min;
            delta_max_current = min(max((-k/(30-10)*obj.spd + k/2+obj.delta_max),delta_min),obj.delta_max); % 10m/s以下转角放开为delta_max，30m/s以上转角最大5°

        end

        %% 子函数： 计算本车距离当前道路终点的距离
        function dist2End = calcDist2End(obj)
            if isempty(obj.planner.current_Road)
                dist2End = 0;
            else
            dist2End = norm(obj.planner.current_Road.lanes{obj.planner.current_lane_id}(end,:)-obj.pos);
            end
        end

        %% 子函数： 随机改变车辆贴图颜色和纯度
        function img_var = var_imgColor(~,img,deviation,purify)
            img_var = img;
            if purify
                for i = 1:size(img,3)
                    img_var(:,:,i)=max(min(img(:,:,i)+deviation(i),255),0);
                end
            else
                img_var=max(min(mean(img,3)-mean(deviation),255),0);
            end
        end
        %******************************************方法结束**************************************************
    end

end