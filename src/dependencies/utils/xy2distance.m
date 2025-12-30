%根据路径x,y坐标序列求出路程序列
function distSequence=xy2distance(x,y)
if(size(x,1)==1)
    x=x';
    y=y';
end
distSequence=[0;cumsum(sqrt(diff(x).^2+diff(y).^2))];

end