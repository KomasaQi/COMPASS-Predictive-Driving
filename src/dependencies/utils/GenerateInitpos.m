function Initpos = GenerateInitpos(Initpos,node1,node2,laneNum,distance_or_percent,roadnet)
lane = roadnet.Roads{node1,node2}.lanes{laneNum};
if distance_or_percent<1
    idx = round(size(lane,1)*distance_or_percent);
else
    distance = xy2dist(lane);
    [~,idx]=min(abs(distance-distance_or_percent));
end
if idx == size(lane,1)
    idx_next = idx-1;
else
    idx_next = idx+1;
end

Initpos.pos = lane(idx,:);
vec = lane(idx_next,:)-lane(idx,:);
[Initpos.head,~] = cart2pol(vec(1),vec(2));

end