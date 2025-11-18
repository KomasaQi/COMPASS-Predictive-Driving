% COMPASS工程的目录，在开始工程的时候从此处打开所需文件

open('DriviingGUI_Test_01.m') % 这是最早的GUI测试文件，可以参考用

open('COMPASS_Run_01.m') % 用于从头初始化本COMPASS场景

open('COMPASS_Checking_01.m') % 用于绘制推演过程的简图动画
open('scenarioOneStep.m') % 用于步进推演过程

open('Checking_DMCST_01.m') % 用于检查get_DynMC_SimTree_route.m，基本上是其的一个拷贝和可任意修改测试版本
open('get_DynMC_SimTree_route.m') % 仿真树搜索

open('realWorldStepOnce.m') % 用于控制SUMO步进一步，同时刷新GUI界面，可以设置更新的步数与刷新频率

open('initCurrentScenario.m') % 用于在预测性决策算法开始时初始化当前场景
open('globalMOBIL.m')
open('src\algorithm\classes\@SimScenario\step.m') % 仿真推演的主程序

% 一般用如下格式进行测试
% COMPASS_Run_01
% for j = 1:10 get_DynMC_SimTree_route; for i = 1 realWorldStepOnce; end ;  end
% 遇到问题进行测试
% COMPASS_Checking_01
% for i = 1:64 scenarioOneStep;end