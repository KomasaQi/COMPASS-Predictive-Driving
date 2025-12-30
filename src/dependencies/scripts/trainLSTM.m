clc
clear
load dataSet.mat

%% 将40组轨迹，分成10份，每份4组数据
% 采用10折交叉验证，随机生成索引值序列
Kfold=10;
NumPerFold=round(length(path_std)/Kfold);
indices = crossvalind('Kfold',length(path_std),Kfold);

%将40组数据按照indices分成10份，存放在元胞数组
path_std_crossvalid = cell(Kfold,NumPerFold);
for i = 1:length(indices)
   for j=1:NumPerFold
       row = indices(i);
       if isempty(path_std_crossvalid{row,j})
           path_std_crossvalid{row,j} = path_std{i,1};
           break
       end
   end
end

%% LSTM网络训练
parSet = {'sgdm','rmsprop','adam'}; %超参数集
parNum=length(parSet);
RMSE_x_mean=zeros(parNum,1);
RMSE_y_mean=zeros(parNum,1);
for i=1:parNum
   RMSE_x_all = zeros(Kfold,NumPerFold);
   RMSE_y_all = zeros(Kfold,NumPerFold);
   
   %第j份数据作为验证集，其余9份作为训练集
   for j =1:Kfold
      %构造训练集和验证集的输入、输出数据
      Xtrain=cell(0);
      Ytrain=cell(0);
      Xtest=cell(0);
      Ytest=cell(0);
      idx=1;
      for k =1:Kfold
         if k ==j
             for n = 1:NumPerFold
                 Xtest{1,n}=path_std_crossvalid{k,n}(:,1:end-1);
                 Ytest{1,n}=path_std_crossvalid{k,n}(:,2:end);
             end
         else
             for n = 1:NumPerFold
                 Xtrain{idx}=path_std_crossvalid{k,n}(:,1:end-1);
                 Ytrain{idx}=path_std_crossvalid{k,n}(:,2:end);
                 idx=idx+1;
             end
         end
      end
      
      %创建LSTM回归网络，指定LSTM层的输入、输出、隐含神经元个数
       numFeatures = 2;
       numResponses = 2;
       numHiddenUnits = 250;
       layers = [sequenceInputLayer(numFeatures)
           lstmLayer(numHiddenUnits)
           fullyConnectedLayer(numResponses)
           regressionLayer];
       
       %指定训练选项
       options = trainingOptions(parSet(i), ...
           'MaxEpochs',500,...
           'GradientThreshold',1,...
           'InitialLearnRate',0.005,...
           'LearnRateSchedule','piecewise',...
           'LearnRateDropPeriod',125,...
           'Verbose',1,...
           'Plots','training-progress');
       %训练LSTM网络
       net = trainNetwork(Xtrain,Ytrain,layers,options);
       
       %利用第j份数据的4组轨迹验证所训练的网络的有效性，并记录RMSE
       for k=1:NumPerFold
           [RMSE_x,RMSE_y]=preTraj(net,Xtest{k},Ytest{k},sig,mu);
           RMSE_x_all(j,k)=RMSE_x;
           RMSE_y_all(j,k)=RMSE_y;
       end 
   end
   
   %计算第i个超参数所有验证结果的RMSE
   RMSE_x_mean(i)= mean(mean(RMSE_x_all));
   RMSE_y_mean(i)= mean(mean(RMSE_y_all));
   
end

[~,idx]=min(RMSE_x_mean);
disp(['-----交叉验证结束，第' num2str(idx) '个超参数' parSet{idx} '最优！ ------'])

%% 重新用最优参数和所有数据训练网络
%重新构造最大的数据集
for i=1:length(path_std)
Xtrain{i}=path_std{i,1}(:,1:end-1);
Ytrain{i}=path_std{i,1}(:,2:end);
end
%重新训练网络
recnet=NetworkTraining(parSet{idx},Xtrain,Ytrain);
%重新验证
RMSE_x_new=zeros(1,NumPerFold);
RMSE_y_new=zeros(1,NumPerFold);
for k=1:NumPerFold
   [RMSE_x_new(k),RMSE_y_new(k)]=preTraj(recnet,Xtest{k},Ytest{k},sig,mu);
end 
RMSE=[mean(RMSE_x_new),mean(RMSE_y_new)];
%% 保存
save trainResult.mat recnet net path_std_crossvalid RMSE RMSE_x_mean RMSE_y_mean Xtrain Ytrain Xtest Ytest

%% 训练网络函数
function recnet=NetworkTraining(param,Xtrain,Ytrain)
      %创建LSTM回归网络，指定LSTM层的输入、输出、隐含神经元个数
       numFeatures = 2;
       numResponses = 2;
       numHiddenUnits = 250;
       layers = [sequenceInputLayer(numFeatures)
           lstmLayer(numHiddenUnits)
           fullyConnectedLayer(numResponses)
           regressionLayer];
       
       %指定训练选项
       options = trainingOptions(param, ...
           'MaxEpochs',500,...
           'GradientThreshold',1,...
           'InitialLearnRate',0.005,...
           'LearnRateSchedule','piecewise',...
           'LearnRateDropPeriod',125,...
           'Verbose',1,...
           'Plots','training-progress');
       %训练LSTM网络
       recnet = trainNetwork(Xtrain,Ytrain,layers,options);

end













