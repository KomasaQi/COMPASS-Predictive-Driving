%% 对4种算法分别进行计算
recalculation=0; %是否重新计算
if recalculation==1
    %初始化规划路径和实际路径存储空间
    Path=cell(4,3);
    Ey=cell(4,2);
    %进行4种算法的仿真
    Tracking_PurePursuit
    Path{1,1}=path;
    Path{1,2}=position;
    Path{1,3}=xy2distance(position(:,1),position(:,2));

    Tracking_Stanley
    Path{2,1}=path;
    Path{2,2}=position;
    Path{2,3}=xy2distance(position(:,1),position(:,2));

    Tracking_LQR
    Path{3,1}=path;
    Path{3,2}=position;
    Path{3,3}=xy2distance(position(:,1),position(:,2));

    Tracking_MPC
    Path{4,1}=path;
    Path{4,2}=position;
    Path{4,3}=xy2distance(position(:,1),position(:,2));
    %关闭所有的窗口
    close
end

%分别计算4种控制方法下的横向误差
for ModelNum=1:4
    %解压变量
    path=Path{ModelNum,1};
    position=Path{ModelNum,2};
    len=Path{ModelNum,3};
    ey=zeros(size(len));
    for i=1:size(position,1)
        idx_tgt=findTargetIdx(position(i,:),path);
        ey(i)=getEy(idx_tgt,path,position(i,:));
    end
    Ey{ModelNum}=ey;
    
end

%% 画图展示结果
figure
subplot(1,2,1);

for ModelNum=1:4
    plot(Path{ModelNum,3},Ey{ModelNum});
    hold on
end
title('四种控制方法横向误差比较');
xlabel('行驶距离/m')
ylabel('横向误差ey/m')
legend('Pure Pursuit','Stanley','LQR','MPC');
grid on
% axis([50 100 -inf inf])
hold off
subplot(1,2,2);
for ModelNum=1:4
    plot(Path{ModelNum,2}(:,1),Path{ModelNum,2}(:,2));
    hold on
end
title('四种控制方法行驶路径');
xlabel('x坐标/m')
ylabel('y坐标/m')
axis equal
legend('Pure Pursuit','Stanley','LQR','MPC');
grid on
hold off
%% 子函数：获取参考轨迹最近的点
function idx=findTargetIdx(pos,path)
dist=zeros(size(path,1),1);
for i=1:size(dist,1)
   dist(i,1)=norm(path(i,1:2)-pos);
end
[~,idx]=min(dist); %找到距离当前位置最近的一个参考轨迹点的序号和距离

end

%% 子函数：获取下一时刻的车轮转角
function ey=getEy(idx_tgt,path,pos)
idx=idx_tgt;
if idx==size(path,1)
    idx=idx-1;
elseif idx==1
    idx=2;
end
diff1=path(idx+1,1:2)-path(idx-1,1:2);
direction0=diff1/norm(diff1);
%参考百度Apollo计算横向误差
dx=pos(1)-path(idx_tgt,1);
dy=pos(2)-path(idx_tgt,2);
refHead=cart2pol(direction0(1),direction0(2));
ey=dx*sin(refHead)-dy*cos(refHead);


end