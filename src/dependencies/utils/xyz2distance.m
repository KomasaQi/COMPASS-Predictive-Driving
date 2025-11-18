%根据路径x,y,z坐标序列求出路程序列
function distSequence=xyz2distance(x,y,z)
if(size(x,1)==1)
    x=x';
    y=y';
    z=z';
end
distSequence=[0;cumsum(sqrt(diff(x).^2+diff(y).^2+diff(z).^2))];

end