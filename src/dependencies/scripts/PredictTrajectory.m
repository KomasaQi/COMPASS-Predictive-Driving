clc
clear
close all 
load trainResult.mat
load dataSet.mat
load Senario.mat
load refInfo.mat
%%  参数定义
%根据测试集的索引号构造输入量，且不取最后一个变量，初始化输出量
CaseNum=15;   %选择测试的工况序列号
Xtest0=Xtrain{1,CaseNum};
Ytest0=Ytrain{1,CaseNum};

%预测时域商都以及其实预测帧等定义
predLen = 5;
frameFlag =50;                                 %从frameFlag开始向后预测
dataNum=size(Xtest0,2);
endFlag = mod(dataNum-frameFlag,predLen); %用于去掉余数那一小截数据
steps = floor((dataNum-frameFlag)/predLen); %滚动预测轨迹的总次数

%% 预测轨迹
%根据起始预测帧初始化预测变量
YPred = Xtest0(:,1:frameFlag);
output_test=[];
%循环滚动预测,每一步预测一帧
for i=1:steps
    for j=1:predLen
        [recnet,YPred_temp]=predictAndUpdateState(recnet,YPred);
        YPred = [YPred,YPred_temp(:,end)];
    end
    
    %追加到输出量
    output_test=[output_test,YPred(:,frameFlag+(i-1)*predLen+1:frameFlag+i*predLen)];

    %预测一个时域结束后，将本时域新增的实际轨迹用来下一次更新网络
    YPred=Xtest0(:,1:frameFlag+i*predLen);
    
end

%根据标准化的sig和mu，获得反标准化的输出值
for i=1:2
   output_test(i,:) = sig(i)*output_test(i,:)+mu(i);
   Ytest0(i,:) = sig(i)*Ytest0(i,:)+mu(i);
end

%预测位置和实际位置
actualPos = Ytest0(:,frameFlag+1:end-endFlag);
predictedPos = output_test;

%% 计算误差
%横纵向的绝对误差
err_x=abs((actualPos(1,:)-predictedPos(1,:)));
err_y=abs((actualPos(2,:)-predictedPos(2,:)));

%横纵向的误差最大值
err_x_max=max(err_x);
err_y_max=max(err_y);

%误差平均值
err_x_mean=mean(err_x);
err_y_mean=mean(err_y);

%均方根误差的平均值
RMSE_x=sqrt(mean((actualPos(1,:)-predictedPos(1,:)).^2));
RMSE_y=sqrt(mean((actualPos(2,:)-predictedPos(2,:)).^2));

%% 画图
% x误差
figure(1)
hold on 
plot(err_x,'r');
plot(err_y,'b');
title('XY两方向上的误差绝对值');
legend('X方向误差','Y方向误差');
xlabel('序列索引');
ylabel('误差/m');
hold off

% 实际轨迹与预测轨迹对比
figure(2)
hold on
plot(actualPos(1,:),actualPos(2,:),'r');
plot(predictedPos(1,:),predictedPos(2,:),'b--');
title('实际轨迹与预测轨迹对比');
legend('实际轨迹','预测轨迹');
xlabel('x坐标/m');
ylabel('y坐标/m');

%% 保存实际轨迹和预测轨迹数据
save predictedResult.mat actualPos predictedPos


