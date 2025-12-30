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