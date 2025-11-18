%% 函数：intersect_linepoly***********
% 基于intersect_lineline来判断一条线段是否和一个多边形相交
% 也可以用来判断一条线段是否和一组线段相交，但效率低
% polygon为 n x 2的向量，是用点序列表示的多边形
function flag=intersect_linepoly(line,poly)
flag=false;
for i=1:size(poly,1)-1
    if intersect_lineline(line,poly(i:i+1,:))
        flag=true;
        break
    end
end
end