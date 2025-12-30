% 车端换道安全仲裁，如果云端换道决策不安全就停止执行，退回当前车道。
function [safe_flag, min_MEI, lc_min_MEI] = SaftyArbitration(ego,vehicleDummies,lc_decision)
    global params %#ok
    safe_flag = false;
    min_MEI = inf;
    veh1 = Vehicle4Mei('x',ego.pos(1),'y',ego.pos(2),'v',ego.speed,'h',ego.heading,'l',ego.length,'w',ego.width);
    for i = 1:length(vehicleDummies)
        vd = vehicleDummies{i};
        veh2 = Vehicle4Mei('x',vd.pos(1),'y',vd.pos(2),'v',vd.speed,'h',vd.heading,'l',vd.length,'w',vd.width);
        [MEI, ~, ~] = mei_q(veh1,veh2,[],[],params.D_SAFE);
        if ~isnan(MEI) && ~isinf(MEI)
            if MEI < min_MEI
                min_MEI = MEI;
            end
        end
    end
    lc_min_MEI = inf;
    veh1 = Vehicle4Mei('x',ego.pos(1) + params.lc_default_dev*sin(ego.heading)*-lc_decision,...
        'y',ego.pos(2) - params.lc_default_dev*cos(ego.heading)*-lc_decision,'v',ego.speed,'h',ego.heading,'l',ego.length,'w',ego.width);
    for i = 1:length(vehicleDummies)
        vd = vehicleDummies{i};
        veh2 = Vehicle4Mei('x',vd.pos(1),'y',vd.pos(2),'v',vd.speed,'h',vd.heading,'l',vd.length,'w',vd.width);
        [MEI, ~, ~] = mei_q(veh1,veh2,[],[],params.D_SAFE);
        if ~isnan(MEI) && ~isinf(MEI)
            if MEI < lc_min_MEI
                lc_min_MEI = MEI;
            end
        end
    end
    if lc_min_MEI < params.min_MEI_thred
        safe_flag = true;
    end
end