classdef SmallMap < handle
    properties (SetAccess = private)
        patches          % m×n cell数组存储图像分块
        patchCenters     % m×n×2 分块中心坐标矩阵
        fullXlim         % 扩展后地图X边界
        fullYlim         % 扩展后地图Y边界
        patchRadius      % 分块半径(米)
        patchSize        % 分块图像尺寸[宽, 高]
        patchMeterPerPixel % 每像素代表的米数
    end
    
    methods
        function obj = SmallMap(patches, centers, xlim, ylim, radius, size)
            % 构造函数
            obj.patches = patches;
            obj.patchCenters = centers;
            obj.fullXlim = xlim;
            obj.fullYlim = ylim;
            obj.patchRadius = radius;
            obj.patchSize = size;
            obj.patchMeterPerPixel = (2 * radius) / size(1);
        end
        
        function [localImg, xlimit, ylimit, xScale, yScale] = getLocalMap(obj, center, real_radius)
            % 计算需要覆盖的完整patch数量
            numPatches = ceil(real_radius / obj.patchRadius);
            
            % 计算中心点所在的patch索引
            centerX = center(1);
            centerY = center(2);
            
            % 找到最近的patch中心
            [~, colIdx] = min(abs(obj.patchCenters(1,:,1) - centerX));
            [~, rowIdx] = min(abs(obj.patchCenters(:,1,2) - centerY));
            
            % 计算需要覆盖的行列范围
            rowStart = max(1, rowIdx - numPatches);
            rowEnd = min(size(obj.patches, 1), rowIdx + numPatches);
            colStart = max(1, colIdx - numPatches);
            colEnd = min(size(obj.patches, 2), colIdx + numPatches);
            
            % 获取一个patch的尺寸
            [h, w, ~] = size(obj.patches{1,1});
            
            % 创建空白图像
            numRows = rowEnd - rowStart + 1;
            numCols = colEnd - colStart + 1;
            localImg = zeros(numRows * h, numCols * w, 3, 'uint8');
            
            % 按正确的地理顺序拼接图像
            currentRow = 1;
            for gridRow = rowStart:rowEnd % 反转行顺序：从大到小
                currentCol = 1;
                for gridCol = colStart:colEnd
                    patchImg = obj.patches{gridRow, gridCol};
                    
                    % 确保patch尺寸一致
                    if ~isequal(size(patchImg), [h, w, 3])
                        patchImg = imresize(patchImg, [h, w]);
                    end
                    
                    % 将patch放入正确位置
                    rowRange = currentRow:(currentRow + h - 1);
                    colRange = currentCol:(currentCol + w - 1);
                    localImg(rowRange, colRange, :) = patchImg;
                    
                    currentCol = currentCol + w;
                end
                currentRow = currentRow + h;
            end
            
            % 计算实际坐标范围
            xmin = min(obj.patchCenters(rowStart:rowEnd, colStart:colEnd, 1), [], 'all') - obj.patchRadius;
            xmax = max(obj.patchCenters(rowStart:rowEnd, colStart:colEnd, 1), [], 'all') + obj.patchRadius;
            ymin = min(obj.patchCenters(rowStart:rowEnd, colStart:colEnd, 2), [], 'all') - obj.patchRadius;
            ymax = max(obj.patchCenters(rowStart:rowEnd, colStart:colEnd, 2), [], 'all') + obj.patchRadius;
            
            xlimit = [xmin, xmax];
            ylimit = [ymin, ymax];
            [h, w, ~] = size(localImg);
            xScale = w/(xmax-xmin);
            yScale = h/(ymax-ymin);
        end



    end
end

% classdef SmallMap < handle
%     properties (SetAccess = private)
%         patches          % m×n cell数组存储图像分块
%         patchCenters     % m×n×2 分块中心坐标矩阵
%         fullXlim         % 扩展后地图X边界
%         fullYlim         % 扩展后地图Y边界
%         patchRadius      % 分块半径(米)
%         patchSize        % 分块图像尺寸[宽, 高]
%     end
% 
%     methods
%         function obj = SmallMap(patches, centers, xlim, ylim, radius, size)
%             % 构造函数
%             obj.patches = patches;
%             obj.patchCenters = centers;
%             obj.fullXlim = xlim;
%             obj.fullYlim = ylim;
%             obj.patchRadius = radius;
%             obj.patchSize = size;
%         end
% 
%         function [localImg, xlimit, ylimit] = getLocalMap(obj, center, real_radius)
%             % 计算目标区域边界
%             xmin = center(1) - real_radius;
%             xmax = center(1) + real_radius;
%             ymin = center(2) - real_radius;
%             ymax = center(2) + real_radius;
% 
%             % 计算像素比例
%             meterPerPixel = (2 * obj.patchRadius) / obj.patchSize(1);
%             imgWidth = round(2 * real_radius / meterPerPixel);
%             imgHeight = round(2 * real_radius / meterPerPixel);
% 
%             % 创建空白图像
%             localImg = zeros(imgHeight, imgWidth, 3, 'uint8');
% 
%             % 计算覆盖的分块索引范围
%             [m, n, ~] = size(obj.patchCenters);
%             colStart = max(1, floor((xmin - obj.fullXlim(1)) / (2 * obj.patchRadius)) + 1);
%             colEnd = min(n, ceil((xmax - obj.fullXlim(1)) / (2 * obj.patchRadius)));
%             rowStart = max(1, floor((ymin - obj.fullYlim(1)) / (2 * obj.patchRadius)) + 1);
%             rowEnd = min(m, ceil((ymax - obj.fullYlim(1)) / (2 * obj.patchRadius)));
% 
%             % 拼接分块图像
%             for i = rowStart:rowEnd
%                 for j = colStart:colEnd
%                     % 获取当前分块
%                     patchImg = obj.patches{i,j};
%                     centerX = obj.patchCenters(i,j,1);
%                     centerY = obj.patchCenters(i,j,2);
% 
%                     % 计算分块在目标图像中的位置
%                     patchXmin = centerX - obj.patchRadius;
%                     patchYmin = centerY - obj.patchRadius;
% 
%                     % 计算重叠区域
%                     overlapXmin = max(xmin, patchXmin);
%                     overlapXmax = min(xmax, patchXmin + 2*obj.patchRadius);
%                     overlapYmin = max(ymin, patchYmin);
%                     overlapYmax = min(ymax, patchYmin + 2*obj.patchRadius);
% 
%                     % 转换到图像坐标
%                     targetX1 = round((overlapXmin - xmin) / meterPerPixel) + 1;
%                     targetX2 = round((overlapXmax - xmin) / meterPerPixel);
%                     targetY1 = round((overlapYmin - ymin) / meterPerPixel) + 1;
%                     targetY2 = round((overlapYmax - ymin) / meterPerPixel);
% 
%                     srcX1 = round((overlapXmin - patchXmin) / meterPerPixel) + 1;
%                     srcX2 = round((overlapXmax - patchXmin) / meterPerPixel);
%                     srcY1 = round((overlapYmin - patchYmin) / meterPerPixel) + 1;
%                     srcY2 = round((overlapYmax - patchYmin) / meterPerPixel);
% 
%                     % 边界镜像处理
%                     [srcX1, srcX2, srcY1, srcY2] = obj.mirrorEdges(...
%                         srcX1, srcX2, srcY1, srcY2, obj.patchSize(1), obj.patchSize(2));
% 
%                     % 复制图像数据
%                     localImg(targetY1:targetY2, targetX1:targetX2, :) = ...
%                         patchImg(srcY1:srcY2, srcX1:srcX2, :);
%                 end
%             end
% 
%             % 返回坐标范围
%             xlimit = [xmin, xmax];
%             ylimit = [ymin, ymax];
%         end
%     end
% 
%     methods (Access = private)
%         function [x1, x2, y1, y2] = mirrorEdges(~, x1, x2, y1, y2, maxW, maxH)
%             % 边界镜像处理
%             if x1 < 1
%                 x1 = 1 - x1;
%                 x2 = 1 - x2;
%                 [x1, x2] = deal(min(x1,x2), max(x1,x2));
%             end
%             if x2 > maxW
%                 overflow = x2 - maxW;
%                 x2 = maxW;
%                 x1 = max(1, x1 - overflow);
%             end
%             if y1 < 1
%                 y1 = 1 - y1;
%                 y2 = 1 - y2;
%                 [y1, y2] = deal(min(y1,y2), max(y1,y2));
%             end
%             if y2 > maxH
%                 overflow = y2 - maxH;
%                 y2 = maxH;
%                 y1 = max(1, y1 - overflow);
%             end
%         end
%     end
% end
