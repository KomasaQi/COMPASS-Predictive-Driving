%% 定义路网文件位置和名称
roadnetFileName = 'lianyg_yanc.net.xml';
saveRootPath = [pwd '\data\maps\'];
roadnetFilePath = [saveRootPath roadnetFileName];
mapName = strrep(roadnetFileName, '.net.xml', '');
DatafileName = [saveRootPath 'ProcessedMap_' mapName '_w_type.mat'];
if exist(DatafileName,'file') == 2
    disp(['数据文件' DatafileName '已经存在,未生成新文件嘻嘻'])
else
%% 将XML文件读取为struct格式
disp(['正在读取文件' roadnetFileName '中，请稍安勿躁，通常需要几秒到几分钟~'])
tic;
map = parseXML(roadnetFilePath);
timeReadingFile = toc;
disp(['文件读取成功！CPU时间花费：' num2str(timeReadingFile) '秒'])
%% 构建实体字典和关系字典
disp('正在构建实体字典、关系字典中~')
tic;
[entity_dict,connection_dict,to_connection_dict,type_dict] = StoreMapDictionary(map);
new_entity_dict = correctInternalLanesShape(entity_dict,connection_dict);
[lane_from_connection_dict, lane_to_connection_dict] = genLaneConnectionDict(connection_dict);
timeReadingFile = toc;
disp(['字典构建完成！CPU时间花费：' num2str(timeReadingFile) '秒']);
disp('正在生成节点邻接地图~')
proxyMat = genProxyMapFromMap(map,entity_dict);
disp('生成节点邻接地图完成！')
disp('正在构建车道指示箭头字典与邻接地图中~')
tic;
dirArrowMap = genDirectionArrowMap(entity_dict,connection_dict);
timeReadingFile = toc;
disp(['车道指示箭头字典与邻接地图构建完成！CPU时间花费：' num2str(timeReadingFile) '秒']);
disp('正在进行道路绘图，转换成用于小地图显示的数据格式中~')
tic
smallMap = saveMapImage_and_Scale(entity_dict,mapName);
timeReadingFile = toc;
disp(['小地图数据构建完成！CPU时间花费：' num2str(timeReadingFile) '秒']);
%% 保存处理好的路网数据
disp('正在保存处理好的地图数据！')
save(DatafileName,'map','connection_dict','entity_dict','proxyMat','dirArrowMap', ...
    'smallMap','new_entity_dict','to_connection_dict','lane_to_connection_dict','lane_from_connection_dict','type_dict')
disp(['数据文件' DatafileName '保存成功~'])
end


%% 子函数库
function [entity_dict,connection_dict,to_connection_dict,type_dict] = StoreMapDictionary(map)
    entity_dict = dictionary(); % 初始化实体字典
    connection_dict = dictionary(string([]),{}); % 初始化关系字典
    to_connection_dict = dictionary(string([]),{}); % 初始化to关系字典
    type_dict = dictionary(string([]),{});  % 道路类型字典
    processFlag = false;
    childrenNum = length(map.Children);
    if childrenNum > 1000
        processFlag =true;
    end
    for i = 1:childrenNum
        theChild = map.Children(i);
       if strcmp(theChild.Name,'junction')
            id = getAttribute(theChild,'id'); 
            if ~strncmp(id,':',1) % 这里暂时省略掉了internal Junction
                junction = Junction_SUMO('id',id,...
                    'type',getAttribute(theChild,'type'), ...
                    'x',str2double(getAttribute(theChild,'x')), ...
                    'y',str2double(getAttribute(theChild,'y')), ...
                    'incLanes',split(getAttribute(theChild,'incLanes'), ' '), ...
                    'intLanes',split(getAttribute(theChild,'intLanes'), ' '), ...
                    'shape',parseStringToMatrix(getAttribute(theChild,'shape')) ...
                    );
                entity_dict(id) = {junction};
            end

       elseif strcmp(theChild.Name,'edge')
            id = getAttribute(theChild,'id'); 
            
            if strncmp(id, ':', 1) % 如果第一个字符是':'，那么是internalEdge
                laneNum = 0;
                for j = 1:length(theChild.Children)
                    if strcmp(theChild.Children(j).Name,'lane')
                        laneNum = laneNum + 1;
                        LaneChild = theChild.Children(j);
                        id0 = getAttribute(LaneChild,'id');
                        lane = Lane_SUMO('id',id0, ...
                            'index',round(str2double(getAttribute(LaneChild,'index'))), ...
                            'speed',str2double(getAttribute(LaneChild,'speed')), ...
                            'length',str2double(getAttribute(LaneChild,'length')), ...
                            'shape',parseStringToMatrix(getAttribute(LaneChild,'shape')));
                        entity_dict(id0) = {lane};
                    end
                end
                edge = Edge_SUMO('id',id,'laneNum',laneNum);

            else
                
                laneNum = 0;
                for j = 1:length(theChild.Children)
                    if strcmp(theChild.Children(j).Name,'lane')
                        laneNum = laneNum + 1;
                        LaneChild = theChild.Children(j);
                        id0 = getAttribute(LaneChild,'id');
                        lane = Lane_SUMO('id',id0, ...
                            'index',round(str2double(getAttribute(LaneChild,'index'))), ...
                            'speed',str2double(getAttribute(LaneChild,'speed')), ...
                            'length',str2double(getAttribute(LaneChild,'length')), ...
                            'shape',parseStringToMatrix(getAttribute(LaneChild,'shape')));
                        entity_dict(id0) = {lane};
                    end
                end
                edge = Edge_SUMO('id',id,'laneNum',laneNum,...
                    'from',getAttribute(theChild,'from'), ...
                    'to',getAttribute(theChild,'to'),...
                    'type',getAttribute(theChild,'type'));
            end
            entity_dict(id) = {edge};

            

       elseif strcmp(theChild.Name,'connection')   
            id = getAttribute(theChild,'from');
            if ~isKey(connection_dict,id) % 如果以这个edge为起始的connection第一次见到
                tempContainner = cell(1,20);
                connect_from_edgeID = struct('connection_num',0,...
                    'connections',{tempContainner});
                connection_dict(id) = {connect_from_edgeID};
            end
              
            connection = Connection_SUMO('from',getAttribute(theChild,'from'), ...
                'to',getAttribute(theChild,'to'), ...
                'fromLane',round(str2double(getAttribute(theChild,'fromLane'))), ...
                'toLane',round(str2double(getAttribute(theChild,'toLane'))), ...
                'via',getAttribute(theChild,'via'), ...
                'dir',getAttribute(theChild,'dir'), ...
                'state',getAttribute(theChild,'state'));
            oldConnectNum = connection_dict{id}.connection_num;
            connection_dict{id}.connection_num = oldConnectNum + 1;
            connection_dict{id}.connections{oldConnectNum+1} = connection;

            id = getAttribute(theChild,'to');
            if ~isKey(to_connection_dict,id) % 如果以这个edge为终止的connection第一次见到
                tempContainner = cell(1,20);
                connect_from_edgeID = struct('connection_num',0,...
                    'connections',{tempContainner});
                to_connection_dict(id) = {connect_from_edgeID};
            end
              
            oldConnectNum = to_connection_dict{id}.connection_num;
            to_connection_dict{id}.connection_num = oldConnectNum + 1;
            to_connection_dict{id}.connections{oldConnectNum+1} = connection;

       elseif strcmp(theChild.Name,'type')
            id = getAttribute(theChild,'id');
            speed_lim = ones(1,3)*str2double(getAttribute(theChild,'speed'));
            for j = 1:length(theChild.Children)
                restrict_child = theChild.Children(j);
                vClass = getAttribute(restrict_child,'vClass');
                new_lim = str2double(getAttribute(restrict_child,'speed'));
                % 对不同车型的特殊规定（如果存在这样的独立条款）就进行特殊限速
                if strcmpi(vClass,'private')
                    speed_lim(1) = new_lim;
                elseif strcmpi(vClass,'truck')
                    speed_lim(2) = new_lim;
                elseif strcmpi(vClass,'trailer')
                    speed_lim(3) = new_lim;
                end

            end
            road_type = Type_SUMO('id',id,'priority',str2double(getAttribute(theChild,'priority')),...
                    'speed_lim',speed_lim);


            type_dict(id) = {road_type};
            
       end

       if processFlag && mod(i,500)==0
            disp(['字典提取处理进度：' num2str(i) '节点/' num2str(childrenNum) '节点'])
       end
    end
end


function new_entity_dict = correctInternalLanesShape(entity_dict,connection_dict)
    new_entity_dict = entity_dict;
    keys = new_entity_dict.keys;
    for i = 1:length(keys)
        key = keys{i};
        entity = new_entity_dict{key};
        if isa(entity,'Edge_SUMO')
            if ~strncmp(key,':',1)
                if isKey(connection_dict,key)
                    for j = 1:connection_dict{key}.connection_num
                        connection = connection_dict{key}.connections{j};
                        fromLaneID = [connection.from '_' num2str(connection.fromLane)];
                        viaLaneID = connection.via;
    
                        toLaneID = [connection.to '_' num2str(connection.toLane)];
                        viaLaneEntity = new_entity_dict{viaLaneID};
                        viaLaneEntity.shape = genIntLaneShape(new_entity_dict{fromLaneID}.shape,new_entity_dict{toLaneID}.shape);
                        dist = xy2dist(viaLaneEntity.shape);
                        viaLaneEntity.length = dist(end,:);
                        new_entity_dict{viaLaneID} = viaLaneEntity;
                    end
                end
            end
        end
    
    end
end

function smallMapObj = saveMapImage_and_Scale(entity_dict, ~, radius)
    if nargin < 3
        radius = 2000; % 默认半径600米
    end
    
    % 绘制完整路网
    fig = figure('Visible', 'on');
    hold on
    keys = entity_dict.keys;
    for i = 1:length(keys)
        entity = entity_dict{keys(i)};
        if isa(entity, 'Lane_SUMO') && ~strncmp(entity.id, ':', 1)
            plot(entity.shape(:,1), entity.shape(:,2), "Color", [0.1 0.1 0.05], "LineWidth", 0.5);
        elseif isa(entity, 'Junction_SUMO')
            fill(entity.shape(:,1), entity.shape(:,2), 'r', 'FaceAlpha', 0.3);
        end
    end
    hold off
    ax = gca;
    
    % 设置图形属性
    axis equal tight off
    color = [0.6 0.65 0.65] * 1.2;
    set([gca, fig], 'Color', color);
    set(fig, 'InvertHardcopy', 'off');
    
    % 获取路网边界并扩展
    xlimit = get(gca, 'XLim');
    ylimit = get(gca, 'YLim');
    expanded_xlim = [xlimit(1)-2*radius, xlimit(2)+2*radius];
    expanded_ylim = [ylimit(1)-2*radius, ylimit(2)+2*radius];
    
    % 计算分块参数
    x_centers = expanded_xlim(1)+radius : 2*radius : expanded_xlim(2)-radius;
    y_centers = expanded_ylim(1)+radius : 2*radius : expanded_ylim(2)-radius;
    y_centers = y_centers(end:-1:1);
    [m, n] = deal(length(y_centers), length(x_centers));
    
    % 初始化分块存储
    patchCell = cell(m, n);
    centerGrid = zeros(m, n, 2);
    
    % 生成并保存每个分块
    for i = 1:m
        for j = 1:n
            % 设置当前分块范围
            x_range = [x_centers(j)-radius, x_centers(j)+radius];
            y_range = [y_centers(i)-radius, y_centers(i)+radius];
            xlim(ax, x_range);
            ylim(ax, y_range);
            
            % 捕获分块图像
            tempImg = getframe(ax);
            patchCell{i,j} = frame2im(tempImg);
            centerGrid(i,j,:) = [x_centers(j), y_centers(i)];
            disp(['正在保存小地图patch中，进度：' num2str((i-1)*n+j) '/' num2str(m*n) '块'])
        end
        
    end
    avg_x = zeros(m*n,1);
    avg_y = zeros(m*n,1);
    counter = 0;
    for i = 1:m
        for j = 1:n
            counter = counter + 1;
            sz = size(patchCell{i,j});
            avg_y(counter) = sz(1);
            avg_x(counter) = sz(2);
        end
    end
    avg_x = round(mean(avg_x));
    avg_y = round(mean(avg_y));

    for i = 1:m
        for j = 1:n
            sz = size(patchCell{i,j});
            disp(['正在统一小地图patch尺寸中，进度：' num2str((i-1)*n+j) '/' num2str(m*n) '块'])
            if avg_y == sz(1) && avg_x == sz(2)
                continue
            else
                patchCell{i,j} = imresize(patchCell{i,j},[avg_y,avg_x]);
            end
            
        end
    end
    disp('小地图patch生成并校正完成！')
    % 获取分块图像尺寸
    [h, w, ~] = size(patchCell{1,1});
    
    % 创建SmallMap对象
    disp('正在创建SmallMap对象的实例中……')
    smallMapObj = SmallMap(patchCell, centerGrid, expanded_xlim, expanded_ylim, radius, [w, h]);
    disp('SmallMap对象实例创建完成！')
    close(fig);
end


% function smallMap = saveMapImage_and_Scale(entity_dict,mapName)
%     fig = figure;
%     hold on
%     keys = entity_dict.keys;
%     for i  = 1:length(keys)
%         entity = entity_dict{keys(i)};
% 
%         if isa(entity,'Lane_SUMO')
%             if ~strncmp(entity.id,':',1)
%                 shape = entity.shape;
%                 plot(shape(:,1),shape(:,2),"Color",[0.1 0.1 0.05], "LineWidth", 0.5)
%             end
%         elseif isa(entity,'Junction_SUMO')
%             shape = entity.shape;
%             fill(shape(:,1),shape(:,2),'r','FaceAlpha',0.3)
%         end
% 
%     end
%     hold off
%     ax = gca;
% 
%     axis equal
%     % axis auto
%     axis off
%     axis tight
% 
%     color = [0.6 0.65 0.65]*1.2;
%     set(gca,'Color',color) % 
%     set(fig,'Color',color) % 深蓝灰,更蓝
%     set(fig, 'InvertHardcopy', 'off');
%     imgFileName = [mapName '.jpg'];
%     exportgraphics(ax,imgFileName,Resolution=1200,BackgroundColor=color);
%     xlimit = get(gca, 'XLim');
%     ylimit = get(gca, 'YLim');
%     close(fig);
%     img = imread(imgFileName);
%     % 获取图像大小
%     [imgHeight, imgWidth, ~] = size(img);
% 
%     % 计算坐标到像素的转换比例
%     yScale = imgWidth / (xlimit(2) - xlimit(1));
%     xScale = imgHeight / (ylimit(2) - ylimit(1));
%     smallMap = struct('img',img,'xlimit',xlimit,'ylimit',ylimit,'xScale',xScale,'yScale',yScale);
% end
