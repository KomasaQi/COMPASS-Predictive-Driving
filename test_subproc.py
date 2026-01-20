
import numpy as np
from stable_baselines3.common.vec_env import SubprocVecEnv, DummyVecEnv
import gymnasium as gym
import compass_env
import time


def make_env(rank: int, base_port: int = 12000, seed: int = 0):
    def _init():
        cfg = {
            "simulation": {
                "traci_port": base_port + rank,
                "traci_label": f"compass-r{rank}",
            },
        }
        env = gym.make("compass-highway-v2", config=cfg, render_mode=None, verbose=False)
        return env
    return _init

if __name__ == "__main__":
    n_envs = 4
    env = DummyVecEnv([make_env(i) for i in range(n_envs)])
    # env = SubprocVecEnv([make_env(i) for i in range(n_envs)], start_method="spawn")
    obs = env.reset()
    tic = time.time()
    for t in range(100):
        actions = np.random.uniform(-1, 1, size=(n_envs, 2)).astype(np.float32)
        obs, rewards, dones, infos = env.step(actions)
        # obs, rewards, dones, infos = env.step([[0, 0] for _ in range(n_envs)])

        if (t % 50) == 0:
            print(f"t={t}, reward_mean={rewards.mean():.3f}, done_count={dones.sum()}")

        # 如果任何环境 done，vecenv 会自动在下一次 step 前 reset；不同实现略有差异
        # 这里不强求手动 reset
    env.close()
    toc = time.time()
    print(f"rollout {t} steps in {toc - tic:.3f} seconds")
    print("rollout ok")
