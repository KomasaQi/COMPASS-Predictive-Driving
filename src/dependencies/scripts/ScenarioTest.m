scenario = drivingScenario('SampleTime',0.02);
roadCenters = [-50,50,0;-50,-50,0;0,0,0;50,50,0;50,-50,0];
lspec = lanespec(2);
%建立道路
marking = [laneMarking('Solid') ...
	laneMarking('Dashed') laneMarking('Solid')];          %分界线线型
laneSpecification = lanespec(2,'Marking',marking);        %道路规范
road(scenario,roadCenters,'Lanes',laneSpecification );    %生成道路

% 获得道路边界，先把边界点位置重新整理次序
rdbdy = roadBoundaries(scenario);
rdbdy=rdbdy{1,1}(1:end-1,:);
rdbdy=[rdbdy(3:end,:);rdbdy([1 2],:)];

%% 构建车辆信息
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

v = vehicle(scenario,'ClassID',1);
waypoints = rightWaypoints;
speeds = (15*linspace(0.1,2,size(waypoints,1))').^1.5;
trajectory(v,waypoints,speeds)

plot(scenario,'Waypoints','off','RoadCenters','on')
while advance(scenario)
    pause(0.1)
end