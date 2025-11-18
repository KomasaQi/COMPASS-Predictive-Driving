%% 函数：SplinePath()****************************
% 通过输入的插值点cv和点数ptNum，根据CV点的距离生成
% 尽可能均匀的插值。
function path = SplinePath(cv,ptNum)
t0=xy2distance(cv(:,1),cv(:,2));
t=linspace(t0(1),t0(end),ptNum)';
path=[pchip(t0,cv(:,1),t),pchip(t0,cv(:,2),t)];
end