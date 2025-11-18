function path=fit3Dcurve(cv,tspan,Ts,plotfcn)
%要求cv是n x 3的向量，一共n个插值关键点
%最终获得一条过散点的3维空间的曲线
tseq=linspace(0,1,size(cv,1));
time=(tspan(1):Ts:tspan(2))';
t=time/(tspan(2)-tspan(1))-tspan(1);
path=[spline(tseq,cv(:,1),t),...
      spline(tseq,cv(:,2),t),...
      spline(tseq,cv(:,3),t)];
if strcmp(plotfcn,'showcurve')
    plot3(path(:,1),path(:,2),path(:,3),'r','linewidth',2);
    hold on
    grid on
    title('散点拟合曲线')
    scatter3(cv(:,1),cv(:,2),cv(:,3),100,'bs','markerfacecolor','g');
    legend('拟合曲线','控制点')
    hold off
end
end