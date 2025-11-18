clc
clear
close all 
load dataSet.mat
load Senario.mat
load refInfo.mat

%% 将左右车道中心线路径点（交通车行驶路径）进行标准化处理
refinfo_obs1_std=zeros(size(refinfo_obs1));
refinfo_obs2_std=zeros(size(refinfo_obs2));
for i=1:2
    refinfo_obs1_std(:,i)=(refinfo_obs1(:,i)-mu(i))/sig(i);
    refinfo_obs2_std(:,i)=(refinfo_obs2(:,i)-mu(i))/sig(i);
end
%% 参数定义
%根据测试集的索引号构造输入量，且不取最后一个变量，初始化输出量
input1=refinfo_obs1_std(1:end-1,:)';
input2=refinfo_obs2_std(1:end-1,:)';

%预测时域长度及起始预测帧等定义
predLen = 80;
frameFlag1 =80;                                 %从frameFlag开始向后预测
frameFlag2=60;

%% 预测轨迹
load trainResult.mat net
%根据起始预测帧初始化预测变量
YPred1 = input1(:,1:frameFlag1);
%循环滚动预测,每一步预测一帧
for i=1:size(input1,2)-frameFlag1-1
    for j=1:predLen
        [net,YPred_temp]=predictAndUpdateState(net,YPred1);
        YPred1 = [YPred1,YPred_temp(:,end)];
    end
    
    %追加到输出量
    output1_x(i,:)=YPred1(1,frameFlag1+1:end);
    output1_y(i,:)=YPred1(2,frameFlag1+1:end);

    %预测一个时域结束后，将本时域新增的实际轨迹用来下一次更新网络
    YPred1=input1(:,i+1:frameFlag1+i);
    disp(num2str(i/(size(input1,2)-frameFlag1-1+(size(input2,2)-frameFlag2-1))*100))
    
end
load trainResult.mat net
%根据起始预测帧初始化预测变量
YPred2 = input2(:,1:frameFlag2);
%循环滚动预测,每一步预测一帧
for i=1:size(input2,2)-frameFlag2-1
    for j=1:predLen
        [net,YPred_temp]=predictAndUpdateState(net,YPred2);
        YPred2 = [YPred2,YPred_temp(:,end)];
    end
    
    %追加到输出量
    output2_x(i,:)=YPred2(1,frameFlag2+1:end);
    output2_y(i,:)=YPred2(2,frameFlag2+1:end);

    %预测一个时域结束后，将本时域新增的实际轨迹用来下一次更新网络
    YPred2=input2(:,i+1:frameFlag2+i);
    disp(num2str((size(input1,2)-frameFlag1-1+i)/(size(input1,2)-frameFlag1-1+(size(input2,2)-frameFlag2-1))*100))
end
%% 处理
%根据标准化的sig和mu，获得反标准化的输出值
for i=1:size(output1_x,1)
   output1_x(i,:) = sig(1)*output1_x(i,:)+mu(1);
   output2_x(i,:) = sig(1)*output2_x(i,:)+mu(1);
end
for i=1:size(output1_y,1)
   output1_y(i,:) = sig(2)*output1_y(i,:)+mu(2);
   output2_y(i,:) = sig(2)*output2_y(i,:)+mu(2);
end

% 转成时序变量
time1=(0:0.1:(size(output1_x,1)-1)/10)+frameFlag1*0.1;
time2=(0:0.1:(size(output2_x,1)-1)/10)+frameFlag2*0.1;
obsPrePos1_x=timeseries(output1_x,time1);
obsPrePos1_y=timeseries(output1_y,time1);
obsPrePos2_x=timeseries(output2_x,time2);
obsPrePos2_y=timeseries(output2_y,time2);
%% 画图展示预测结果
figure(1)
hold on
for i=1:size(obsPrePos1_x.Data,1)
   plot(obsPrePos1_x.Data(i,:),obsPrePos1_y.Data(i,:)) 
   
end
for i=1:size(obsPrePos2_x.Data,1)
   plot(obsPrePos2_x.Data(i,:),obsPrePos2_y.Data(i,:)) 
   
end
hold off


%% 保存实际轨迹和预测轨迹数据
save obsPre.mat obsPrePos1_x obsPrePos1_y obsPrePos2_x obsPrePos2_y




