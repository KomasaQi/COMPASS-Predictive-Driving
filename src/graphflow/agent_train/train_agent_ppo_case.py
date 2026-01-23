import os
import sys
import traceback
import time
import numpy as np
import torch
from stable_baselines3.common.vec_env import SubprocVecEnv, DummyVecEnv
import gymnasium as gym
from stable_baselines3 import PPO
# 确保导入Monitor
from stable_baselines3.common.monitor import Monitor
from models import EgoAttentionExtractor,EgoTransformerExtractor
import tensorboard
from stable_baselines3.common.callbacks import EvalCallback, CallbackList, BaseCallback
from scheduler import cosine_annealing_schedule, linear_schedule
from train_agent_ppo import RewardLoggingCallback, CrashLogger, make_env


# ========== 关键修复：将项目根目录添加到Python路径 ==========
# 获取当前脚本所在目录
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
# 获取项目根目录（根据你的路径结构调整，这里假设脚本在src/graphflow/agent_train/下）
PROJECT_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "../../.."))
# 将项目根目录添加到Python搜索路径
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

import compass_env
from compass_env.utils import vis_matrix


print(f"当前工作目录: {os.getcwd()}")
print(f"项目根目录已添加到路径: {PROJECT_ROOT}")

# ========== 新增：定义监控日志根目录 ==========
LOG_DIR = "./outputs/compass_transformer_ppo/"
TENSORBOARD_LOG_DIR = "E:/runs/compass_transformer_ppo/"
MONITOR_LOG_ROOT = os.path.join(LOG_DIR, "monitor_logs")
os.makedirs(MONITOR_LOG_ROOT, exist_ok=True)

# 要记录到TensorBoard的自定义奖励字段（和Monitor中的info_keywords一致）
REWARD_KEYS = [
    "ttc_inv_penalty", "mei_reward", "rttc_inv_reward", "hw_penalty", "safe_reward",
    "collision_penalty", "speed_reward", "effi_reward", "allowed_lane_reward",
    "mission_reward", "navi_reward", "keep_right_reward", "speed_limit_reward",
    "rule_reward", "acc_reward", "comf_reward", "lane_change_reward",
    "lc_block_penalty", "repeat_lc_penalty", "opt_reward"
]



# ==================================
#        Main script
# ==================================

if __name__ == "__main__":
    print(f"主进程工作目录: {os.getcwd()}")
    print(f"监控日志将保存到: {MONITOR_LOG_ROOT}")
    
    env_config = {
        "case_num": -1,
        "reload_state": False,
        "random_seed_range": 10,
    }
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    train = True
    if train:
        
        n_envs = 4
        n_test_envs = 4
        # 创建子进程环境（已包含Monitor）
        env = SubprocVecEnv([make_env(i, config=env_config, verbose=False) for i in range(n_envs)], start_method="spawn")
    
        eval_env = SubprocVecEnv([make_env(i + n_envs, config=env_config, verbose=False, ) for i in range(n_test_envs)], start_method="spawn")

        # Create Callback
        eval_callback = EvalCallback(eval_env=eval_env, 
                                     best_model_save_path=LOG_DIR,
                                     log_path=MONITOR_LOG_ROOT, 
                                     eval_freq=1000, 
                                     verbose=1,deterministic=True,n_eval_episodes=10)
        # 创建自定义奖励日志回调
        reward_log_callback = RewardLoggingCallback(reward_keys=REWARD_KEYS, verbose=1)
        # 组合所有回调
        combined_callback = CallbackList([reward_log_callback, eval_callback])
        
        network_kwargs = dict(
            embedding_layer_kwargs = {"state_channel": 53,
                                      "history_channel":24,
                                      "dim": 128,
                                      "hist_steps":20,
                                      "state_attn_encoder":True,
                                      "state_dropout":0.0,
                                      "presence_index": 1,
                                      "v_type_index": -1},
            attention_layer_kwargs = {"feature_dim": 128, "heads": 4, "num_layers": 2},
        )
        policy_kwargs = dict(
            net_arch=[dict(pi=[128, 128], vf=[128, 128])],
            features_extractor_class = EgoTransformerExtractor,
            features_extractor_kwargs = network_kwargs,
        )
  
        # model = PPO(
        #     "MultiInputPolicy",
        #     env,
        #     n_steps = 1024 // n_envs,
        #     batch_size = 256,
        #     learning_rate = cosine_annealing_schedule(1e-3, 1e-4),
        #     policy_kwargs = policy_kwargs,
        #     verbose = 2,
        #     tensorboard_log = TENSORBOARD_LOG_DIR,
        #     device = device,
        # )
        model = PPO.load(os.path.join(LOG_DIR, "best_model_128_full3"), env=env, device=device)
        model.n_steps = 512 // n_envs
        model.batch_size = 128
        model.learning_rate = cosine_annealing_schedule(1e-3, 1e-4)
        model.tensorboard_log = TENSORBOARD_LOG_DIR
        
        # Train the agent
        model.learn(total_timesteps=450 * 1000, progress_bar=True, callback=eval_callback)
        # Save the agent
        # 确保输出目录存在
        os.makedirs(LOG_DIR, exist_ok=True)
        model.save(os.path.join(LOG_DIR, "model_trans_128_case_001")) 
        env.close()
    
    # 测试环境也添加Monitor
    model = PPO.load(os.path.join(LOG_DIR, "model_trans_128_case_001"), device='cpu')
    # 创建测试环境（包含Monitor）
    test_env_func = make_env(0, config=env_config, render_mode="human", verbose=True)
    test_env = test_env_func()  # 执行_env函数创建实际环境
    visualize_attn = False # 是否可视化注意力矩阵
    
    for _ in range(5):
        obs, info = test_env.reset()
        done = truncated = False
        while not (done or truncated):
            action, _ = model.predict(obs,deterministic=True)
            obs, reward, done, truncated, info = test_env.step(action)
            if visualize_attn:
                # 获取注意力矩阵
                obs_th = {'ego': torch.from_numpy(obs['ego']).unsqueeze(0), 'veh': torch.from_numpy(obs['veh']).unsqueeze(0)}
                entity_num = obs_th['veh'].shape[1] + 1 # 包含自车
                attention = model.policy.features_extractor.get_attention_matrix(obs_th).reshape(-1, entity_num)
                # 可视化注意力矩阵
                vis_matrix(attention.detach().numpy())
    
    # 关闭测试环境
    test_env.close()