classdef MOBIL
%{
MOBIL模型 Kesting等人于2007年提出（最小化由换道行为引发的总体减速模型）
minimizing overall braking induced by lane changes
该模型用车辆加速度值表征驾驶者所得的驾驶利益，通过比较换道实施前后，当前车道与目标
车道上受影响车辆的整体利益变化来判断是否进行换道，并针对对称和非对称换道规则其除了相应的
换道模型。
MOBIL考察3辆车利益，本车，原车道后车，目标车道的新后车。换道需求建模：加速度
驾驶人对车道的选择本质上是看其在那条车道上能获得最大加速度。
另车辆ego选择第k条车道的效用值为U_ego_k,则有U_ego_k = a_ego_k
 
换道安全准则
目标车道后车加速度约束：间隙约束的间接描述
_hat表示换道后的值

(a_ego_hat - a_ego) + p*((a_hat_fhat - a_fhat)+(a_hat_f - a_f)) > delta_a + a_bias

p为礼让系数，p=0时只考虑自身利益，p=1时平等考虑自身和他人利益
detla_a为一个阈值，a_bias反应不对称换道情况。当交通规则倾向于驾驶人靠右侧车道行驶时
从左侧车道向右侧换道的门槛较低a_bias<0,反之a_bias>0。当左右换道具有同等权利时，a_bias=0

对于换道后新的跟随车辆，换道行为需要满足如下安全条件：
a_hat_fhat = f(v_fhat,v_ego,s_hat_fhat) > -b_safe
其中f是跟驰模型
%}
    properties
        p            % politeness礼让系数[0,1]
        delta_a      % 加速度收益阈值
        a_bias       % 加速度偏置（非对称换道和对称换道）[a_left, a_right]
    end
    methods
        function obj = MOBIL(p,delta_a,a_bias)
            obj.p       = p;
            obj.delta_a = delta_a;
            obj.a_bias  = a_bias; %[a_left, a_right]
        end
        
    end

end