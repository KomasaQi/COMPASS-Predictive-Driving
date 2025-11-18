% 需要加载地图，如果没加载就加载一下
% load TsinghuaMap.mat map;

figure(1)
hold on

for i = 1:length(map.Children)
    if strcmp(map.Children(i).Name,'edge')
        for j = 1:length(map.Children(i).Children)
        edgeLine_string = getAttribute(map.Children(i).Children(j),'shape');
        if ~isempty(edgeLine_string)
            edgeLine = parseStringToMatrix(edgeLine_string);
            plot(edgeLine(:,1),edgeLine(:,2),'k')
        end
        end
    % elseif strcmp(map.Children(i).Name,'junction')
    %     edgeLine_string = getAttribute(map.Children(i),'shape');
    %     if ~isempty(edgeLine_string)
    %         edgeLine = parseStringToMatrix(edgeLine_string);
    %         fill(edgeLine(:,1),edgeLine(:,2),'r')
    %     end
    end

end
axis equal
hold off



