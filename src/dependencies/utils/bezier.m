function [path,time]=bezier(cv,tspan,Ts,plotfcn)
if nargin < 2 || isempty(tspan)
    tspan = [0 1];
end
if nargin < 3 || isempty(Ts)
    Ts = 0.01;
end
if nargin < 4 || isempty(plotfcn)
    plotfcn = 'nothing';
end
time=(tspan(1):Ts:tspan(2))';
t=time/(tspan(2)-tspan(1));
order=size(cv,1);
path=zeros(length(t),2);

if strcmp(plotfcn,'showbase')
base=zeros(length(t),size(cv,1));
end

for i=1:length(t)
    B=zeros(1,order);
    for j=1:order
        B(j)=nchoosek(order-1,j-1).*(1-t(i)).^(order-j).*t(i).^(j-1);
    end
    path(i,:)=B*cv;
    
    if strcmp(plotfcn,'showbase')
    base(i,:)=B;
    end

end
if strcmp(plotfcn,'showbase')
    figure
    plot(t,base);
    title('Bezier曲线基函数');
    xlabel('参数 t');
    ylabel('基');
end


end