import os
import sys
import traceback
import time
import numpy as np
from stable_baselines3.common.vec_env import SubprocVecEnv, DummyVecEnv
import gymnasium as gym
import models


# ========== 关键修复：将项目根目录添加到Python路径 ==========
# 获取当前脚本所在目录
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
# 获取项目根目录（根据你的路径结构调整，这里假设脚本在src/graphflow/agent_train/下）
PROJECT_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "../../.."))
# 将项目根目录添加到Python搜索路径
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)


import compass_env


print(f"当前工作目录: {os.getcwd()}")
print(f"项目根目录已添加到路径: {PROJECT_ROOT}")

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


def make_env(rank: int, base_port: int = 12000, seed: int = 0):
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
        env = gym.make("compass-highway-v2", config=cfg, render_mode=None, verbose=False)
        env = CrashLogger(env, rank)
        return env
    return _init

if __name__ == "__main__":
    print(f"主进程工作目录: {os.getcwd()}")
    n_envs = 4
    # env = DummyVecEnv([make_env(i) for i in range(n_envs)])
    env = SubprocVecEnv([make_env(i) for i in range(n_envs)], start_method="spawn")
    
 
    obs = env.reset()
    tic = time.time()
    for t in range(500):
        obs, rewards, dones, infos = env.step([[0, 0] for _ in range(n_envs)])
        
        if (t % 50) == 0:
            print(f"t={t}, reward_mean={rewards.mean():.3f}, done_count={dones.sum()}")
    
    env.close()
    toc = time.time()
    print(f"rollout {t} steps in {toc - tic:.3f} seconds")
    print("rollout ok")
        
