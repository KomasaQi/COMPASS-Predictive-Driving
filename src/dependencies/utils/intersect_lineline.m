%% 函数：intersect_lineline**********
%判断两条线段是否相交，返回逻辑值1或0
function flag=intersect_lineline(line1,line2) %#codegen
flag=false;
[A,B]=sortPoint(line1);
[C,D]=sortPoint(line2);
% 1-检测线段CD的两个断电是否位于线段AB两边
AB=B-A;
AC=C-A;
AD=D-A;
result1=cross2d(AB,AC);
result2=cross2d(AB,AD);

% 2-检测线段AB的两个端点是否位于线段CD两边
CD=D-C;
CB=B-C;
result3=cross2d(CD,-AC);
result4=cross2d(CD,CB);

% 3-判断两条线段是否相交
if result1*result2<0  && result3*result4<0 ||...
   result1*result2==0 && result3*result4<0 ||...
   result1*result2<0  && result3*result4==0
   %若两条线为X型，或T型，则相交
   flag=true;
elseif result1==0 && result2==0 && result3==0 && result4==0
    %4个都为0，表明两条线段共线，但是否重合需要进一步判断
    %由于线段端点已经排序，只需要排除共线但不重合的情况即可
    if (C(1)<B(1) || D(1)<A(1) ||... %x方向
         C(2)<B(2) || D(2)<A(2) )     %y方向
        flag=true;
    end
end

end

%% 子函数:sortPoint******************
%按照如下规则对线段的两个点进行排序：
%如果x坐标不相等，x坐标小的为p1
%如果x坐标相等，y坐标小的为p1
%以此类推，直到最后一个维度
%line形式为：2 x dim，2个点，dim为点的维度
function [p1,p2]=sortPoint(line)
p1=line(1,:);
p2=line(2,:);
for dim=1:size(line,2)
    if(line(1,dim)==line(2,dim))
        continue
    elseif(line(1,dim)<line(2,dim))
        break
    else
        p1=line(2,:);
        p2=line(1,:);
    end
end
end

%% 子函数：
function val=cross2d(vec1,vec2)
val=vec1(1)*vec2(2)-vec1(2)*vec2(1);
end