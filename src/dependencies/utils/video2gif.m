% 打开存放想要转换成gif的视频的文件夹，并输入拓展名类型，就可以在本文件夹生成所有gif
function video2gif(extendName,downsample,skipframe)
    if nargin < 1 || isempty(extendName)
        extendName = 'mp4';
    end
    if nargin < 2 || isempty(downsample)
        downsample = 2;
    end
    if nargin < 3 || skipframe
        skipframe = 0;
    end

    % 获取当前工作文件夹中的所有视频文件
    videoFiles = dir(fullfile(pwd, ['*.' extendName]));  % 可以修改扩展名，支持其他格式（如 .avi, .mov 等）
    
    % 遍历每个视频文件
    for i = 1:length(videoFiles)
        videoFileName = videoFiles(i).name;  % 获取视频文件名
        videoFilePath = fullfile(videoFiles(i).folder, videoFileName);  % 获取视频文件完整路径
    
        % 读取视频文件
        videoObj = VideoReader(videoFilePath);
        
        % 获取输出 GIF 文件名
        [~, fileNameWithoutExt, ~] = fileparts(videoFileName);  % 获取不带扩展名的文件名
        gifFileName = fullfile(pwd, [fileNameWithoutExt, '.gif']);  % 输出 GIF 文件路径
    
        % 初始化GIF文件
        firstFrame = true;
        
        % 遍历每一帧，将其转换为 GIF 格式
        counter = 0;
        while hasFrame(videoObj)
            frame = readFrame(videoObj);  % 读取一帧
            counter = counter + 1;
            if skipframe && mod(counter,skipframe) 
                continue
            end
            img_size = size(frame);
            if downsample && max(img_size) > 800
                img_size = floor(img_size./downsample);
                frame = imresize(frame,img_size(1:2));
            end
            % 将每帧数据转换为图像格式 (RGB)
            [imind, cm] = rgb2ind(frame, 256);  % 将RGB图像转换为索引图像
            
            % 写入GIF文件
            if firstFrame
                % 如果是第一帧，创建 GIF 文件
                imwrite(imind, cm, gifFileName, 'gif', 'Loopcount', inf, 'DelayTime', 1/videoObj.FrameRate);
                firstFrame = false;
            else
                % 后续帧附加到 GIF 文件中
                imwrite(imind, cm, gifFileName, 'gif', 'WriteMode', 'append', 'DelayTime', 1/videoObj.FrameRate);
            end
        end
        fprintf('转换完成: %s -> %s\n', videoFileName, gifFileName);
    end

end