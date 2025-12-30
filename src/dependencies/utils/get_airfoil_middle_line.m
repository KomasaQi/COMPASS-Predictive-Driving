%%% find the middle line of an airfoil
% author: KomasaQi
% institude: Tsinghua Univ. SVM
% date: 2024/6/27
% input: wing, scatter points of an airfoil exported by profilli, n x 2 array
%        ptNum, interpolate point number that you want.
% output: middleLine, ptNum x 2 array

function middleLine = get_airfoil_middle_line(wing,ptNum)
    x = wing(:,1);
    y = wing(:,2);
    id_left = find(x==min(x));
    x_up = x(1:id_left);
    y_up = y(1:id_left);
    x_dn = x(id_left:end);
    y_dn = y(id_left:end);
    t = linspace(min(x),max(x),ptNum)';
    
    
    middlePt = linspace(min(x),max(x),20);
    interp_x_up = interp1(x_up,y_up,middlePt);
    interp_x_dn = interp1(x_dn,y_dn,middlePt);
    
    middleLine = [t,pchip(middlePt,(interp_x_up+interp_x_dn)/2,t)];

end