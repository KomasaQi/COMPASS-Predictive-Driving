function inter_veh_eql_dist = InterVehEqlDist(pos_ego, head_ego, ego_len, pos_veh, veh_len)
    direct_vec = [cos(head_ego), sin(head_ego)];
    veh_vec = (pos_veh-pos_ego);
    proj_dist =  dot((direct_vec'*direct_vec)*veh_vec',direct_vec);
    tot_len = (ego_len + veh_len)/2;
    [theta,dist] = cart2pol(veh_vec(1),veh_vec(2));
    thth = head_ego-theta;
   
    dist = max([0 dist-tot_len*(0.5+0.5*cos(2*thth))]); 
    % 计算等效距离
    inter_veh_eql_dist = dist*sign(proj_dist)*(min((abs(tan(thth))+1).^2-0,1));
end
