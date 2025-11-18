%% 函数：intersect_polypoly***********
% 基于intersect_linepoly来判断两个多边形是否相交
% 也可以用来判断两组线段是否相交，但效率低
% polygon为 n x 2的向量，是用点序列表示的多边形
function flag=intersect_polypoly(poly1,poly2)
flag=false;
for i=1:size(poly1,1)-1
    if intersect_linepoly(poly1(i:i+1,:),poly2)
        flag=true;
        break
    end
end
end