function  [xlimit,ylimit]=getBoxVisionLimit(vehicles)
veh_num = length(vehicles);
positions = zeros(veh_num,2);

for i = 1:veh_num
    pos = vehicles{i}.pos;
    positions(i,:)=pos;
end
pos_min = min(positions);
pos_max = max(positions);
len_x = pos_max(1) - pos_min(1);
len_y = pos_max(2) - pos_min(2);
max_len = max([len_x,len_y]);
box_len = max_len*0.6;
mean_pos = (pos_max+pos_min)/2;
xlimit = mean_pos(1)+[-1 1]*box_len;
ylimit = mean_pos(2)+[-1 1]*box_len;
end