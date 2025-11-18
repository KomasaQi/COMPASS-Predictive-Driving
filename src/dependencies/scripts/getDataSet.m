clc 
clear
close all

%% 初始参数定义
SampleNum=40;           
path = cell(SampleNum,1); %数据集一共40条路径
obsSpeed=10;             %交通车速度
for i = 1:SampleNum
    % 构建道路场景
    %场景初始化
    scenario = drivingScenario; %初始化场景
    scenario.SampleTime = 0.1; %修改采样时间

    %道路中心坐标
    pos = i+19;
    roadCenters=[-pos,pos,0;-pos,-pos,0;0,0,0;pos,pos,0;pos,-pos,0];

    %建立道路
    marking = [laneMarking('Solid') ...
        laneMarking('Dashed') laneMarking('Solid')]; %分界线线型
    laneSpecification = lanespec(2,'Marking',marking);        %道路规范
    road(scenario,roadCenters,'Lanes',laneSpecification );    %生成道路

    % 获得道路边界，先把便捷点位置重新整理次序
    rdbdy = roadBoundaries(scenario);
    rdbdy=rdbdy{1,1}(1:end-1,:);
    rdbdy=[rdbdy(3:end,:);rdbdy([1 2],:)];
    
    %根据单向两车道约定，分别计算左车道和右车道的中心线坐标，以生成车辆航迹点
    ptNums= size(rdbdy,1);
    leftWaypoints=zeros(ptNums/2,size(rdbdy,2));
    rightWaypoints=zeros(size(leftWaypoints));
    for j =1:ptNums/2
       rightBdyPt = rdbdy(j,:) ;
       leftBdyPt=rdbdy(ptNums+1-j,:);
       leftWaypoints(j,:)=leftBdyPt+(rightBdyPt-leftBdyPt)*0.25;
       rightWaypoints(j,:)=leftBdyPt+(rightBdyPt-leftBdyPt)*0.75;
    end
    %生成车辆行驶轨迹
    iniPos = leftWaypoints(1,:);
    myVehicle= vehicle(scenario,'Position',iniPos);
    trajectory(myVehicle,leftWaypoints,obsSpeed);
    
    while advance(scenario)
       currentPos = scenario.Actors.Position;
       path{i}(:,end+1)=currentPos([1 2])';
    end
    %清空变量
    clear scenario
    disp(['已完成' num2str(i) '/' num2str(SampleNum) '个样本的仿真----' num2str(i/SampleNum*100) '%'])
end

%% 标准化处理
%混合成两行数据，用于标准化（才能获取数据集最大值和最小值）
mixData=[];
for i=1:SampleNum
   mixData = [mixData,path{i}];
end

%统一进行标准化为具有零均值和单位方差的数据集
mixData_std=zeros(size(mixData));
DOF=size(mixData,1);
mu=zeros(DOF,1);
sig=zeros(DOF,1);
for i =1:DOF
   mu(i)=mean(mixData(i,:)) ;
   sig(i)=std(mixData(i,:));
   mixData_std(i,:)=(mixData(i,:)-mu(i))/sig(i);
end

%再把标准化之后的数据归类到原来的元胞数组里面
flag=1;
path_std=cell(size(path));
for i=1:SampleNum
   len=length(path{i}) ;
   path_std{i,1}=mixData_std(:,flag:flag+len-1);
   flag=flag+len;
end
%% 绘制标准化数据集图形
figure(1)
hold on
for i=1:SampleNum
    x=path_std{i}(1,:);
    y=path_std{i}(2,:);
    plot(x,y);
end
hold off

%% 保存
save dataSet.mat path path_std mu sig







