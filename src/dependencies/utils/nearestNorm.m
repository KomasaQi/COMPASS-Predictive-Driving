function norm_vec = nearestNorm(p1,p2,direction)
    v = p2 - p1; % 从p1指向p2的向量
    v_clk90 =  [-v(2),  v(1)];
    cos_th_clk90 = calcAngleCos(v_clk90,direction);
    if cos_th_clk90 > 0
        norm_vec = v_clk90/norm(v);
    else
        norm_vec = [ v(2), -v(1)]/norm(v);
    end
end

function cos_th = calcAngleCos(v1,v2)
    cos_th = dot(v1,v2)/norm(v1)/norm(v2);
end
