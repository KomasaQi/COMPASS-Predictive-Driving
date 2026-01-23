import os
import sys
import time
import numpy as np
import torch
import json
from stable_baselines3 import PPO
# 确保导入Monitor
from stable_baselines3.common.monitor import Monitor
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
from compass_env.utils import vis_matrix, print_reward, REWARD_KEYS, init_reward_dict, create_gif


print(f"当前工作目录: {os.getcwd()}")
print(f"项目根目录已添加到路径: {PROJECT_ROOT}")

# ========== 新增：定义监控日志根目录 ==========
LOG_DIR = "./outputs/compass_transformer_ppo/"
RESULT_DIR = os.path.join(LOG_DIR, "batch_eval_compare_parallel")

LOG_DIR = "./outputs/compass_transformer_ppo/"
RESULT_DIR = os.path.join(LOG_DIR, "batch_eval_compare_parallel")

result_path = os.path.join(RESULT_DIR, "better_seeds_20260123_122203.json")
result_file = json.load(open(result_path, "r"))

render_path = "compass_env/output/"
save_dir = "assets/gif/"

# ==================================
#        Main script
# ==================================

if __name__ == "__main__":
    print(f"主进程工作目录: {os.getcwd()}")
    
    env_config = {"case_num": 1, "test_mode": True, "auto_mode": True,}
    test_env_idm_func = make_env(0, config=env_config, render_mode="rgb_array", verbose=False)
    test_env_idm = test_env_idm_func()  # 执行_env函数创建实际环境
    
    env_config = {"case_num": 1, "test_mode": True, "auto_mode": False,}
    test_env_rl_func = make_env(1, config=env_config, render_mode="rgb_array", verbose=False)
    test_env_rl = test_env_rl_func()  # 执行_env函数创建实际环境
    
    
    model = PPO.load(os.path.join(LOG_DIR, "model_trans_128_case_001"), device="cpu")
    # model = PPO.load(os.path.join(LOG_DIR, "best_model_128_case"), device='cpu')
    
    

    test_case_number = 1
    recored_best_id = 0
    frame_rate = 25
    
    for case_id in range(1, test_case_number+1):
        seed = result_file[str(int(case_id))][recored_best_id]['seed']
        case_name = f"case{case_id}-no-{recored_best_id + 1}-seed-{seed}"
        
        # 测试IDM+MOBIL
        sumo_reward_dict = init_reward_dict()
        sumo_case_name = case_name + "-idm"
        test_env_idm.unwrapped.config["gui"]["cache_img_name"] = render_path + sumo_case_name + ".png"
        obs, info = test_env_idm.reset(seed=seed,options={"case_id":case_id})
        done = truncated = False
        while not (done or truncated):
            test_env_idm.render()
            obs, reward, done, truncated, info = test_env_idm.step([0,0])
            time.sleep(0.05)
            for key in REWARD_KEYS:
                sumo_reward_dict[key] += info[key]
        print(f"Case {case_id} IDM+MOBIL reward: {sumo_reward_dict['reward']:.4f}")
        print_reward(sumo_reward_dict)
        create_gif(case_name=sumo_case_name, render_path=render_path, save_dir=save_dir,frame_rate=frame_rate,remove_image=True)
    
        # 测试PPO
        rl_reward_dict = init_reward_dict()
        rl_case_name = case_name + "-ppo"
        test_env_rl.unwrapped.config["gui"]["cache_img_name"] = render_path + rl_case_name + ".png"
        obs, info = test_env_rl.reset(seed=seed,options={"case_id":case_id})
        done = truncated = False
        while not (done or truncated):
            test_env_rl.render()
            action, _ = model.predict(obs,deterministic=True)
            time.sleep(0.05)
            obs, reward, done, truncated, info = test_env_rl.step(action)
            for key in REWARD_KEYS:
                rl_reward_dict[key] += info[key]
        print(f"Case {case_id} PPO reward: {rl_reward_dict['reward']:.4f}")
        print_reward(rl_reward_dict)
        create_gif(case_name=rl_case_name, render_path=render_path, save_dir=save_dir,frame_rate=frame_rate,remove_image=True)

        time.sleep(5)
    
    test_env_idm.close()
    test_env_rl.close()
    
    
