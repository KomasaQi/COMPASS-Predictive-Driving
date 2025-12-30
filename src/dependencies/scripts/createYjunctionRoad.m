scenario = drivingScenario;
ls = lanespec(2,'Width',5);
% Add the first road
roadCenters = [-20 0; 6 0];
road(scenario,roadCenters,'Name','Road 1','Lanes',ls);

% Add the second road
roadCenters = [23 7; 50 33];
road(scenario,roadCenters,'Name','Road 2','Lanes',ls);

% Add the third road
roadCenters = [23 -7; 50 -33];
road(scenario,roadCenters,'Name','Road 3','Lanes',ls);

figure
plot(scenario)

rg = driving.scenario.RoadGroup('Name','Y-Junction');
roadWidth = 10;

% Add the first road segment
roadCenters = [23 7; 14 1; 6 0];
road(rg,roadCenters,roadWidth,'Name','Segment 1');

% Add the second road segment
roadCenters = [23 -7; 14 -1; 6 0];
road(rg,roadCenters,roadWidth,'Name','Segment 2');

% Add the third road segment
roadCenters = [23 7; 21 4; 21 -4; 23 -7];
road(rg,roadCenters,roadWidth,'Name','Segment 3');

roadGroup(scenario,rg);