
function [x1,y1]=RotatePolygon(x,y,center,th)
pointNum=length(x);
if length(x)~=length(y)
    disp('顶点x,y坐标不一致，请检查一下')
end
x1=zeros(size(x));
y1=zeros(size(y));
for i=1:pointNum
    xc=x(i)-center(1);
    yc=y(i)-center(2);
    x1(i)=(xc*cos(th)-yc*sin(th))+center(1);
    y1(i)=(xc*sin(th)+yc*cos(th))+center(2);
end

end