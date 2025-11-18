function [MEI, TEM, InDepth] = mei_q(veh1, veh2,tf,Ts,D_safe)
    % 对默认参数进行赋值
    if nargin < 3 || isempty(tf)
        tf = 5;
    end
    if nargin < 4 || isempty(Ts)
        Ts = 0.2;
    end
    if nargin < 5 || isempty(D_safe)
        D_safe = 0;
    end
    
    % 情况1:无论如何两车车头都要计算
    [~, ~, ~, InDepth, MEI, TEM, ~, ~] = ...
        compute_SSM_mex(veh1.x, veh1.y, veh1.v, veh1.h, veh1.l, veh1.w,...
                        veh2.x, veh2.y, veh2.v, veh2.h, veh2.l, veh2.w, D_safe);

    if ~veh1.has_trailer && veh2.has_trailer
        % 当车辆2有挂车，我们计算一次1车车头和2车挂车的风险
        [MEI_t, TEM_t, InDepth_t] = trailer_mei_mex(tf, Ts, D_safe, ...
            veh1.x, veh1.y, veh1.v, veh1.h, veh1.l, veh1.w,...
            veh2.x, veh2.y, veh2.v, veh2.h, veh2.l, veh2.w, veh2.lb, veh2.gamma, veh2.l_t, veh2.w_t);
        % 更新风险指标
        [MEI,TEM,InDepth] = refreshIndex(MEI,TEM,InDepth,MEI_t,TEM_t,InDepth_t);

    elseif veh1.has_trailer && ~veh2.has_trailer
        % 当车辆1有挂车，我们计算一次2车车头和1车挂车的风险
        [MEI_t, TEM_t, InDepth_t] = trailer_mei_mex(tf, Ts, D_safe, ...
            veh2.x, veh2.y, veh2.v, veh2.h, veh2.l, veh2.w,...
            veh1.x, veh1.y, veh1.v, veh1.h, veh1.l, veh1.w, veh1.lb, veh1.gamma, veh1.l_t, veh1.w_t);
        % 更新风险指标
        [MEI,TEM,InDepth] = refreshIndex(MEI,TEM,InDepth,MEI_t,TEM_t,InDepth_t);

    elseif veh1.has_trailer && veh2.has_trailer
        % 当两车都有挂车，我们计算挂车之间的风险
        [MEI_t, TEM_t, InDepth_t] = trailer2_mei_mex(tf, Ts, D_safe, ...
            veh1.x, veh1.y, veh1.v, veh1.h, veh1.l, veh1.w, veh1.lb, veh1.gamma, veh1.l_t, veh1.w_t,...
            veh2.x, veh2.y, veh2.v, veh2.h, veh2.l, veh2.w, veh2.lb, veh2.gamma, veh2.l_t, veh2.w_t);
        % 更新风险指标
        [MEI,TEM,InDepth] = refreshIndex(MEI,TEM,InDepth,MEI_t,TEM_t,InDepth_t);
    end

end

function [MEI_new,TEM_new,InDepth_new] = refreshIndex(MEI,TEM,InDepth,MEI_t,TEM_t,InDepth_t)
    % 对指标进行更新
    if TEM_t < TEM || isnan(TEM)
        TEM_new = TEM_t;
    end
    if MEI_t > MEI || isnan(MEI)
        MEI_new = MEI_t;
    end
    if InDepth_t > InDepth  || isnan(InDepth)
        InDepth_new = InDepth_t;
    end
end
