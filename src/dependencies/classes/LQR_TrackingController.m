classdef LQR_TrackingController
    properties
        Q
        R
        Ts %控制步长，单位：s
        L  %轴距
    end

    methods 
        function obj = LQR_TrackingController(ctrller_params)
            if nargin < 1
                obj.Q  = diag([1,1,10]);
                obj.R  = diag([1,1]);
                obj.Ts = 0.02;  
                obj.L  = 2.9;
            else
                obj.Q  = ctrller_params.Q;
                obj.R  = ctrller_params.R;
                obj.Ts = ctrller_params.Ts;
                obj.L  = ctrller_params.L;
            end
        end

        %% 子函数：获取参考轨迹最近的点
        function idx=findTargetIdx(~,pos,path)
        dist = sum([(path(:,1)-pos(1)).^2,(path(:,2)-pos(2)).^2],2);
        [~,idx]=min(dist); %找到距离当前位置最近的一个参考轨迹点的序号和距离
        end

        %% 子函数:LQR控制器
        function ddelta=LQR_ctrl(obj,pos,head,path,v,delta)
            [delta_ref, refHeading] = obj.getDeltaRefandRefHead(path);
            idx = obj.findTargetIdx(pos,path);
            refHead = refHeading(idx);
            refDelta = delta_ref(idx);
        dt = obj.Ts;
        %求位置、航向角偏差量
        ex=pos(1)-path(idx,1);
        ey=pos(2)-path(idx,2);
        eh=head-refHead;
        X=[ex;ey;eh];
        %由状态方程系数矩阵，计算K
        A=[1,   0,   -v*dt*sin(refHead);
           0,   1,   v*dt*cos(refHead);
           0,   0,         1             ];
        B=[cos(refHead),          0;
           sin(refHead),          0;
           tan(refDelta)/obj.L,  v/(obj.L*cos(refDelta)^2)]*dt;
        K=obj.RicattiForLQR(A,B,obj.Q,obj.R);
        %获得前轮速度变化量、前轮转角变化量两个控制量
        u=-K*X;  %2×1
        %获取相对参考量的控制变化量输出
        ddelta_ref=u(2);  
        %对转角变化量进行变换
        delta_tmp=refDelta+ddelta_ref;
        ddd=delta_tmp-delta;
        ddelta=sign(ddd)*min([abs(ddd),dt*90/180*pi]);
        end

        function K=RicattiForLQR(~,A,B,Q,R)
            iter_max=500;
            P0=Q;
            P=zeros(size(Q));
            iter=0;
            while (max(max(abs(P0-P)))>eps)
                iter=iter+1;
                if iter==iter_max
                    break
                end
                P= Q + A'*P0*A - (A'*P0*B)*((R+B'*P0*B)\(B'*P0*A));
                P0=P;
            end
            K=(B'*P*B + R)\(B'*P*A);
        end
        
        function [delta_ref, refHead] = getDeltaRefandRefHead(obj, path)
            cur=curvature(path(:,1),path(:,2));
            % 获得参考前轮转角
            delta_ref=atan(cur.*obj.L); 
            %获得参考航向角
            diff_x=diff(path(:,1));
            diff_y=diff(path(:,2));
            refHead = atan2(diff_y,diff_x);
            refHead(end+1)=refHead(end);    
        end

    end

end