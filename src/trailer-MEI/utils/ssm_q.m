function [ACT, v_closest, Shortest_D, InDepth, MEI, TEM, DTC, v_norm] = ssm_q(veh_A, veh_B, D_safe)
% 计算安全指标
[ACT, v_closest, Shortest_D, InDepth, MEI, TEM, DTC, v_norm] = ...
    compute_SSM_mex(veh_A.x, veh_A.y, veh_A.v, veh_A.h, veh_A.l, veh_A.w,...
                    veh_B.x, veh_B.y, veh_B.v, veh_B.h, veh_B.l, veh_B.w, D_safe);

end