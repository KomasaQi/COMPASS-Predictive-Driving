import os
import sys
import traceback
import time
import numpy as np
import torch
from stable_baselines3.common.vec_env import SubprocVecEnv, DummyVecEnv
import gymnasium as gym
from stable_baselines3 import PPO, SAC
# 确保导入Monitor
from stable_baselines3.common.monitor import Monitor
from models import EgoAttentionExtractor,EgoTransformerExtractor
import tensorboard
from stable_baselines3.common.callbacks import EvalCallback, CallbackList, BaseCallback
from stable_baselines3.common.vec_env import VecNormalize, VecFrameStack
from stable_baselines3 import HerReplayBuffer


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
LOG_DIR = "./outputs/compass_transformer_sac/"
TENSORBOARD_LOG_DIR = "E:/runs/compass_transformer_sac/"
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




# 自定义回调：记录Monitor中的自定义奖励字段到TensorBoard
class RewardLoggingCallback(BaseCallback):
    def __init__(self, reward_keys: list, verbose: int = 0):
        super().__init__(verbose)
        self.reward_keys = reward_keys  # 要记录的自定义奖励字段列表

    def _on_step(self) -> bool:
        # 遍历每个环境的info（VecEnv的info是列表）
        for idx, info in enumerate(self.locals["infos"]):
            # 只在episode结束时记录（避免重复记录）
            if "episode" in info:
                # 记录总奖励（默认已有，可选）
                self.logger.record(f"env_{idx}/total_reward", info["episode"]["r"])
                self.logger.record(f"env_{idx}/episode_length", info["episode"]["l"])
                
                # 记录所有自定义奖励字段
                for key in self.reward_keys:
                    if key in info:
                        self.logger.record(f"env_{idx}/{key}", info[key])
        
        # 强制刷新日志（确保写入TensorBoard）
        self.logger.dump(self.num_timesteps)
        return True


class CrashLogger(gym.Wrapper):
    def __init__(self, env, rank, log_dir="worker_py_crash"):
        super().__init__(env)
        self.rank = rank
        os.makedirs(log_dir, exist_ok=True)
        self.path = os.path.join(log_dir, f"crash_rank{rank}.log")

    def reset(self, **kwargs):
        try:
            return self.env.reset(** kwargs)
        except Exception:
            with open(self.path, "a", encoding="utf-8") as f:
                f.write("\n" + "="*80 + "\n")
                f.write(f"[{time.strftime('%F %T')}] reset() crashed, rank={self.rank}\n")
                f.write(traceback.format_exc())
            raise

    def step(self, action):
        try:
            return self.env.step(action)
        except Exception:
            with open(self.path, "a", encoding="utf-8") as f:
                f.write("\n" + "="*80 + "\n")
                f.write(f"[{time.strftime('%F %T')}] step() crashed, rank={self.rank}\n")
                f.write(traceback.format_exc())
            raise

def make_env(rank: int, base_port: int = 12000, seed: int = 0, 
             config: dict = None, render_mode: str = None, verbose: bool = False):
    def _init():
        # ========== 子进程中也要确保路径正确 ==========
        # 重新添加路径（子进程会继承主进程的sys.path，但保险起见显式添加）
        if PROJECT_ROOT not in sys.path:
            sys.path.insert(0, PROJECT_ROOT)
        
        cfg = {
            "simulation": {
                "traci_port": base_port + rank,
                "traci_label": f"compass-r{rank}",
            },
        }
        if config is not None:
            cfg = _deep_update(cfg, config)
        
        # 1. 创建原始环境
        env = gym.make("compass-highway-v2", config=cfg, render_mode=render_mode, verbose=verbose)
        
        # 2. 关键修改：添加Monitor包装器（核心步骤）
        # 为每个rank创建独立的监控日志目录
        monitor_log_dir = os.path.join(MONITOR_LOG_ROOT, f"env_rank_{rank}")
        os.makedirs(monitor_log_dir, exist_ok=True)
        # 包装Monitor，设置日志文件路径
        env = Monitor(
            env,
            filename=os.path.join(monitor_log_dir, "monitor.csv"),
            info_keywords=(
                "ttc_inv_penalty", "mei_reward", "rttc_inv_reward", "hw_penalty", "safe_reward",
                "collision_penalty", "speed_reward", "effi_reward", "allowed_lane_reward",
                "mission_reward", "navi_reward", "keep_right_reward", "speed_limit_reward",
                "rule_reward", "acc_reward", "comf_reward", "lane_change_reward",
                "lc_block_penalty", "repeat_lc_penalty", "opt_reward"
            )  # 如果需要记录额外的info字段，可以在这里指定，比如("speed", "collision")
        )
        # 3. 保持CrashLogger包装（在Monitor外层）
        env = CrashLogger(env, rank)
        
        return env
    
    def _deep_update(base: dict, new: dict):
        for k, v in new.items():
            if isinstance(v, dict) and isinstance(base.get(k), dict):
                _deep_update(base[k], v)
            else:
                base[k] = v
        return base
    return _init

def make_configure_env(**kwargs):
    env = gym.make(kwargs["id"], render_mode="human", config=kwargs["config"])
    # 为配置环境也添加Monitor
    monitor_log_dir = os.path.join(MONITOR_LOG_ROOT, "configure_env")
    os.makedirs(monitor_log_dir, exist_ok=True)
    env = Monitor(env, os.path.join(monitor_log_dir, "monitor.csv"))
    env.reset()
    return env

# ==================================
#        Main script
# ==================================

if __name__ == "__main__":
    print(f"主进程工作目录: {os.getcwd()}")
    print(f"监控日志将保存到: {MONITOR_LOG_ROOT}")
    
    env_config = {
        "case_num": -1,
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
                                     verbose=1,deterministic=True,n_eval_episodes=5)
        # 创建自定义奖励日志回调
        reward_log_callback = RewardLoggingCallback(reward_keys=REWARD_KEYS, verbose=1)
        # 组合所有回调
        combined_callback = CallbackList([reward_log_callback, eval_callback])
        
        network_kwargs = dict(
            embedding_layer_kwargs = {"state_channel": 53,
                                      "history_channel":24,
                                      "dim": 256,
                                      "hist_steps":20,
                                      "state_attn_encoder":True,
                                      "state_dropout":0.0,
                                      "presence_index": 1,
                                      "v_type_index": -1},
            attention_layer_kwargs = {"feature_dim": 256, "heads": 4, "num_layers": 2},
        )
        policy_kwargs = dict(
            net_arch=dict(pi=[256, 256], qf=[256, 256]),
            features_extractor_class = EgoTransformerExtractor,
            features_extractor_kwargs = network_kwargs,
        )
  
        model = SAC(
            policy="MultiInputPolicy",
            env=env,
            learning_rate=3e-4,
            buffer_size=500_000,
            batch_size=128,
            tau=0.005,
            gamma=0.99,
            train_freq=(100, "step"),
            gradient_steps=10,
            learning_starts=10_000,
            policy_kwargs=policy_kwargs,
            tensorboard_log=TENSORBOARD_LOG_DIR,
            verbose=2,
            device=device,
        )
        # model = SAC.load(os.path.join(LOG_DIR, "model002"), env=env)
        # Train the agent
        model.learn(total_timesteps=100 * 1000, progress_bar=True, callback=eval_callback)
        # Save the agent
        # 确保输出目录存在
        os.makedirs(LOG_DIR, exist_ok=True)
        model.save(os.path.join(LOG_DIR, "model_trans_sac_256_001"))
        env.close()
    
    # 测试环境也添加Monitor
    model = SAC.load(os.path.join(LOG_DIR, "model_trans_256_sac_001"), device='cpu')
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