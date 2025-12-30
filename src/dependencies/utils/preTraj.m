function [RMSE_x,RMSE_y]=preTraj(net,Xtest,Ytest,sig,mu)

%预测时域商都以及其实预测帧等定义
predLen = 10;
frameFlag =50;                                 %从frameFlag开始向后预测
dataNum=size(Xtest,2);
endFlag = mod(dataNum-frameFlag,predLen); %用于去掉余数那一小截数据
steps = floor((dataNum-frameFlag)/predLen); %滚动预测轨迹的总次数

%% 预测轨迹
%根据起始预测帧初始化预测变量
YPred = Xtest(:,1:frameFlag);
output_test=[];
%循环滚动预测
for i=1:steps
    for j=1:predLen
        [net,YPred_temp]=predictAndUpdateState(net,YPred);
        YPred = [YPred,YPred_temp(:,end)];
    end
    
    %追加到输出量
    output_test=[output_test,YPred(:,frameFlag+(i-1)*predLen+1:frameFlag+i*predLen)];

    %预测一个时域结束后，将本时域新增的实际轨迹用来下一次更新网络
    YPred=Xtest(:,1:frameFlag+i*predLen);
    
end

%根据标准化的sig和mu，获得反标准化的输出值
for i=1:2
   output_test(i,:) = sig(i)*output_test(i,:)+mu(i);
   Ytest(i,:) = sig(i)*Ytest(i,:)+mu(i);
end

%预测位置和实际位置
actualPos = Ytest(:,frameFlag+1:end-endFlag);
predictedPos = output_test;

%% 计算误差
RMSE_x=sqrt(mean((actualPos(1,:)-predictedPos(1,:)).^2));
RMSE_y=sqrt(mean((actualPos(2,:)-predictedPos(2,:)).^2));




end