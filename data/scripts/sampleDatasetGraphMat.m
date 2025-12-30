
% 设置基本参数
hist_secs = 20;
skip = 1;
future_secs = 20;
skip_time = 2.5;
jumpto = 74;  % 上次没处理完，现在从第几个文件开始处理
% 首先自定义一个文件进行加载
matFiles = dir([params.sample.savedir, '*.mat']);

all_sample_number = 0;
files_to_process = zeros(1,length(matFiles));
for i = 1:length(matFiles)
    matFile = matFiles(i);
    load(matFile.name,'cloud_db'); % 加载一次运行产生的数据库
    available_time = double(cloud_db.timeVehicleMap.keys); % 整条轨迹所有可用时间戳
    available_frames = length(available_time); % 获取可用总帧数
    sample_bias_idxs = (hist_secs*2 + 1):(skip_time*2):available_frames-round(future_secs*2)-1;
    all_sample_number = all_sample_number + length(sample_bias_idxs);
    files_to_process(i) = length(sample_bias_idxs);
    disp(['正在统计需要生成的文件数，已统计到' num2str(all_sample_number) '个，当前进度统计' num2str(round(i/length(matFiles)*100,2)) '%'])
end
files_to_process_cum = [0,cumsum(files_to_process)]; % 累计已经应该处理了的文件
for i = jumpto:length(matFiles)
    processed_file_num = 0;
    matFile = matFiles(i);
    load(matFile.name,'cloud_db'); % 加载一次运行产生的数据库
    available_time = double(cloud_db.timeVehicleMap.keys); % 整条轨迹所有可用时间戳
    available_frames = length(available_time); % 获取可用总帧数
    sample_bias_idxs = (hist_secs*2 + 1):(skip_time*2):available_frames-round(future_secs*2)-1;
    sample_idxs = 2*(-hist_secs:0.5*(1+skip):future_secs);
    ego_manouver = cloud_db.getEgoManouver();
    for j = 1:length(sample_bias_idxs)
        % 获取整条轨迹上的采样整体偏移序号
        idx = sample_bias_idxs(j);
        theTime = available_time(idx);
        % 设置保存文件位置与名称
        matfile_name = ['data/dataset/CompassGraphDataset/raw/'...
            cloud_db.params.output_dir(8:end) '_' num2str(theTime*10) '.mat'];
        % 提取用于训练的某一帧及基于其裁剪地图的过去与历史帧
        [endNodes,nodeStatFeats,nodeDynFeats,edgeFeats,times,nodes_idx_list,edges_num] = ...
                        genSampleForTraining(cloud_db,theTime,hist_secs,skip,future_secs);
        % 获取对应的动作信息
        action_lc = ego_manouver.lc(idx + sample_idxs);
        action_acc = ego_manouver.acc(idx + sample_idxs);

        % 保存数据文件
        save(matfile_name,"endNodes","nodeStatFeats","nodeDynFeats","edgeFeats",...
            "times","nodes_idx_list","edges_num","action_acc","action_lc",'-v7.3')
        processed_file_num = processed_file_num + 1;
        disp(['保存文件：' matfile_name ' 当前进度：' num2str(round(100*((files_to_process_cum(i)+processed_file_num)/all_sample_number),2)) '%'])
    
    end
end