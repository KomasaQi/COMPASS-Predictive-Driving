
import numpy as np
from stable_baselines3.common.vec_env import SubprocVecEnv, DummyVecEnv
import gymnasium as gym
import compass_env
import time
import os, traceback, time
import gymnasium as gym

class CrashLogger(gym.Wrapper):
    def __init__(self, env, rank, log_dir="worker_py_crash"):
        super().__init__(env)
        self.rank = rank
        os.makedirs(log_dir, exist_ok=True)
        self.path = os.path.join(log_dir, f"crash_rank{rank}.log")

    def reset(self, **kwargs):
        try:
            return self.env.reset(**kwargs)
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
                # 如果你能取到仿真时间/ego状态，最好也写进去
                # f.write(f"sim_time={self.env.sim_time}, ego_alive={...}\n")
                f.write(traceback.format_exc())
            raise


def make_env(rank: int, base_port: int = 12000, seed: int = 0):
    def _init():
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
    n_envs = 4
    # env = DummyVecEnv([make_env(i) for i in range(n_envs)])
    env = SubprocVecEnv([make_env(i) for i in range(n_envs)], start_method="spawn")
    obs = env.reset()
    tic = time.time()
    for t in range(5000):
        # actions = np.random.uniform(-1, 1, size=(n_envs, 2)).astype(np.float32)
        # obs, rewards, dones, infos = env.step(actions)
        obs, rewards, dones, infos = env.step([[0, 0] for _ in range(n_envs)])
        # print("rewards:", rewards)
        if (t % 50) == 0:
            print(f"t={t}, reward_mean={rewards.mean():.3f}, done_count={dones.sum()}")

        # 如果任何环境 done，vecenv 会自动在下一次 step 前 reset；不同实现略有差异
        # 这里不强求手动 reset
    env.close()
    toc = time.time()
    print(f"rollout {t} steps in {toc - tic:.3f} seconds")
    print("rollout ok")
