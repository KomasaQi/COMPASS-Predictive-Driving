clc,clear
%% 2台单车情况
veh1 = Vehicle4Mei('x',0,'y',0,'v',0.1,'h',0,'l',10,'w',2.5);
veh2 = Vehicle4Mei('x',-2,'y',8,'v',5,'h',-1,'l',4.8,'w',1.8);
[MEI, TEM, InDepth] = mei_q(veh1,veh2);
% 显示结果
fprintf('===== 2台单车安全指标计算结果 =====\n');
fprintf('TEM: %.4f s\n', TEM);
fprintf('InDepth: %.4f m\n', InDepth);
fprintf('MEI: %.4f m/s\n', MEI);

%% 1台单车一台半挂情况
veh1 = Vehicle4Mei('x',-15,'y',2,'v',10,'h',0.8,'l',5,'w',1.8);
veh2 = Vehicle4Mei('x',-15,'y',15,'v',11.2,'h',0.5,'l',6,'w',2.5,'lb',1.5,'gamma',-1,'l_t',11,'w_t',2.5);

[MEI, TEM, InDepth] = mei_q(veh1,veh2);
% 显示结果
fprintf('===== 单车+半挂安全指标计算结果 =====\n');
fprintf('TEM: %.4f s\n', TEM);
fprintf('InDepth: %.4f m\n', InDepth);
fprintf('MEI: %.4f m/s\n', MEI);

%% 2台半挂车情况
veh1 = Vehicle4Mei('x',-2,'y',14,'v',2,'h',0.8,'l',5,'w',1.8,'lb',1.5,'gamma',0.8,'l_t',8,'w_t',1.8);
veh2 = Vehicle4Mei('x',-15,'y',15,'v',11.2,'h',0.5,'l',6,'w',2.5,'lb',1.5,'gamma',-1,'l_t',11,'w_t',2.5);
[MEI, TEM, InDepth] = mei_q(veh1,veh2);
% 显示结果
fprintf('===== 2台半挂安全指标计算结果 =====\n');
fprintf('TEM: %.4f s\n', TEM);
fprintf('InDepth: %.4f m\n', InDepth);
fprintf('MEI: %.4f m/s\n', MEI);

%% 带图演示
% drag_line_proj_fast
% SSM_vis
% two_trailer_demo

