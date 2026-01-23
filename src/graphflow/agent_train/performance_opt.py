import os
import sys
import json
import time
import random
import csv
import numpy as np
import torch
from stable_baselines3 import PPO

from train_agent_ppo import make_env
from compass_env.utils import REWARD_KEYS, init_reward_dict

# ========== 路径修复：将项目根目录添加到Python路径 ==========
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "../../.."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

def set_global_seeds(seed: int):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)

def ensure_float_dict(d: dict):
    out = {}
    for k, v in d.items():
        if isinstance(v, (np.floating, np.float32, np.float64)):
            out[k] = float(v)
        elif isinstance(v, (np.integer, np.int32, np.int64)):
            out[k] = int(v)
        else:
            out[k] = float(v) if isinstance(v, (int, float)) else v
    return out

def run_episode_idm(env, seed: int, case_id: int):
    set_global_seeds(seed)
    reward_dict = init_reward_dict()
    obs, info = env.reset(seed=seed, options={"case_id": case_id})
    done = truncated = False
    steps = 0
    while not (done or truncated):
        obs, reward, done, truncated, info = env.step([0, 0])
        for k in REWARD_KEYS:
            reward_dict[k] += float(info.get(k, 0.0))
        steps += 1
    return ensure_float_dict(reward_dict), steps, bool(done), bool(truncated)

def run_episode_rl(env, model, seed: int, case_id: int, deterministic=True):
    set_global_seeds(seed)
    reward_dict = init_reward_dict()
    obs, info = env.reset(seed=seed, options={"case_id": case_id})
    done = truncated = False
    steps = 0
    while not (done or truncated):
        action, _ = model.predict(obs, deterministic=deterministic)
        obs, reward, done, truncated, info = env.step(action)
        for k in REWARD_KEYS:
            reward_dict[k] += float(info.get(k, 0.0))
        steps += 1
    return ensure_float_dict(reward_dict), steps, bool(done), bool(truncated)

def safe_write_json(path: str, obj):
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
    os.replace(tmp, path)

def write_csv(path: str, records):
    header = ["algo", "seed", "case_id", "steps", "done", "truncated", "total_reward"] + [f"r_{k}" for k in REWARD_KEYS]
    tmp = path + ".tmp"
    with open(tmp, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(header)
        for r in records:
            rd = r["reward_dict"]
            row = [
                r["algo"], r["seed"], r["case_id"], r["steps"], int(r["done"]), int(r["truncated"]), r["total_reward"]
            ] + [float(rd.get(k, 0.0)) for k in REWARD_KEYS]
            w.writerow(row)
    os.replace(tmp, path)

if __name__ == "__main__":
    # ===================== 参数 =====================
    LOG_DIR = "./outputs/compass_transformer_ppo/"
    MODEL_PATH = os.path.join(LOG_DIR, "model_trans_128_case_001")
    OUT_DIR = os.path.join(LOG_DIR, "batch_eval_compare")
    os.makedirs(OUT_DIR, exist_ok=True)

    SEED_START = 0
    SEED_END = 100      # inclusive
    CASE_START = 1
    CASE_END = 28       # inclusive

    DETERMINISTIC = True
    RENDER_MODE = None          # 批量评测建议 None
    VERBOSE_ENV = False

    # ========= 打印/保存频率控制 =========
    PRINT_EVERY_RUN = False     # True: 每个(seed,case)都打印一行对比；5656条会很刷屏
    PRINT_EVERY_N = 50          # 每完成 N 个 “episode”（注意不是run）打印一次阶段统计
    CHECKPOINT_EVERY_EP = 200   # 每完成 N 个 episode 就落盘一次（防崩）
    CHECKPOINT_KEEP_LATEST_ONLY = True  # True: 只保留 latest checkpoint（更省空间）

    # ===================== 载入 tqdm（进度条） =====================
    try:
        from tqdm import tqdm
    except ImportError:
        raise ImportError("请先安装 tqdm: pip install tqdm")

    # ===================== 创建环境 =====================
    env_config_idm = {"case_num": 1, "test_mode": True, "auto_mode": True}
    env_config_rl  = {"case_num": 1, "test_mode": True, "auto_mode": False}

    print(f"[INFO] Workdir: {os.getcwd()}")
    print(f"[INFO] Project root: {PROJECT_ROOT}")
    print(f"[INFO] Output dir: {OUT_DIR}")
    print(f"[INFO] Model: {MODEL_PATH}")
    print(f"[INFO] Seeds: {SEED_START}..{SEED_END}  Cases: {CASE_START}..{CASE_END}")
    print(f"[INFO] Deterministic: {DETERMINISTIC}, Render: {RENDER_MODE}")
    print(f"[INFO] Total episodes = {(SEED_END-SEED_START+1)*(CASE_END-CASE_START+1)*2}")

    test_env_idm = make_env(0, config=env_config_idm, render_mode=RENDER_MODE, verbose=VERBOSE_ENV)()
    test_env_rl  = make_env(1, config=env_config_rl,  render_mode=RENDER_MODE, verbose=VERBOSE_ENV)()
    model = PPO.load(MODEL_PATH, device="cpu")

    # ===================== 数据结构 =====================
    records = []
    scores = {case_id: {} for case_id in range(CASE_START, CASE_END + 1)}

    stamp = time.strftime("%Y%m%d_%H%M%S")
    final_json_path = os.path.join(OUT_DIR, f"reward_records_{stamp}.json")
    final_csv_path  = os.path.join(OUT_DIR, f"reward_records_{stamp}.csv")
    final_better_path = os.path.join(OUT_DIR, f"better_seeds_by_case_{stamp}.json")

    latest_json_path = os.path.join(OUT_DIR, "reward_records_latest.json")
    latest_csv_path  = os.path.join(OUT_DIR, "reward_records_latest.csv")
    latest_better_path = os.path.join(OUT_DIR, "better_seeds_by_case_latest.json")

    # ===================== 主循环：带进度条 =====================
    total_pairs = (SEED_END - SEED_START + 1) * (CASE_END - CASE_START + 1)
    total_episodes = total_pairs * 2

    t0 = time.time()
    ep_count = 0

    pbar = tqdm(total=total_episodes, ncols=110, desc="Evaluating episodes", unit="ep")

    def maybe_checkpoint():
        # 先算 better_seeds_by_case（用于 checkpoint 也能看结果）
        better_seeds_by_case = {}
        for case_id in range(CASE_START, CASE_END + 1):
            diffs = []
            for seed in range(SEED_START, SEED_END + 1):
                item = scores[case_id].get(seed, {})
                if "rl" not in item or "idm" not in item:
                    continue
                delta = item["rl"] - item["idm"]
                if delta > 0:
                    diffs.append({"seed": seed, "rl_reward": item["rl"], "idm_reward": item["idm"], "delta": delta})
            diffs.sort(key=lambda x: x["delta"], reverse=True)
            better_seeds_by_case[case_id] = diffs

        # 写 latest
        safe_write_json(latest_json_path, records)
        safe_write_json(latest_better_path, better_seeds_by_case)
        write_csv(latest_csv_path, records)

        if not CHECKPOINT_KEEP_LATEST_ONLY:
            # 保存一个时间戳 checkpoint
            ck_json = os.path.join(OUT_DIR, f"checkpoint_{stamp}_ep{ep_count}.json")
            ck_better = os.path.join(OUT_DIR, f"checkpoint_better_{stamp}_ep{ep_count}.json")
            ck_csv = os.path.join(OUT_DIR, f"checkpoint_{stamp}_ep{ep_count}.csv")
            safe_write_json(ck_json, records)
            safe_write_json(ck_better, better_seeds_by_case)
            write_csv(ck_csv, records)

    try:
        # 额外统计：滚动均值/速度
        last_stat_t = time.time()
        last_stat_ep = 0

        for seed in range(SEED_START, SEED_END + 1):
            for case_id in range(CASE_START, CASE_END + 1):

                # ===== IDM =====
                idm_dict, idm_steps, idm_done, idm_trunc = run_episode_idm(test_env_idm, seed, case_id)
                idm_total = float(idm_dict.get("reward", 0.0))
                records.append({
                    "algo": "IDM",
                    "seed": seed,
                    "case_id": case_id,
                    "steps": idm_steps,
                    "done": idm_done,
                    "truncated": idm_trunc,
                    "reward_dict": idm_dict,
                    "total_reward": idm_total,
                })
                scores[case_id].setdefault(seed, {})
                scores[case_id][seed]["idm"] = idm_total

                ep_count += 1
                pbar.update(1)
                pbar.set_postfix({"seed": seed, "case": case_id, "last": f"IDM {idm_total:.2f}", "steps": idm_steps})

                # ===== RL =====
                rl_dict, rl_steps, rl_done, rl_trunc = run_episode_rl(test_env_rl, model, seed, case_id, deterministic=DETERMINISTIC)
                rl_total = float(rl_dict.get("reward", 0.0))
                records.append({
                    "algo": "RL",
                    "seed": seed,
                    "case_id": case_id,
                    "steps": rl_steps,
                    "done": rl_done,
                    "truncated": rl_trunc,
                    "reward_dict": rl_dict,
                    "total_reward": rl_total,
                })
                scores[case_id].setdefault(seed, {})
                scores[case_id][seed]["rl"] = rl_total

                ep_count += 1
                pbar.update(1)

                delta = rl_total - idm_total
                pbar.set_postfix({"seed": seed, "case": case_id, "last": f"RL {rl_total:.2f}", "Δ": f"{delta:+.2f}"})

                # ===== 可选：每个(seed,case)打印一行（刷屏慎开）=====
                if PRINT_EVERY_RUN:
                    print(f"[RUN] seed={seed:3d} case={case_id:02d}  IDM={idm_total:8.3f}  RL={rl_total:8.3f}  Δ={delta:+8.3f}")

                # ===== 每 N 个 episode 打印一次速度/ETA（除了 tqdm 自带 ETA，再给你一个更明确的）=====
                if ep_count % PRINT_EVERY_N == 0:
                    now = time.time()
                    dt = now - last_stat_t
                    deps = ep_count - last_stat_ep
                    speed = deps / dt if dt > 1e-6 else float("inf")  # ep/s
                    elapsed = now - t0
                    remain = total_episodes - ep_count
                    eta_sec = remain / speed if speed > 1e-6 else float("inf")
                    print(f"[STAT] {ep_count}/{total_episodes} ep done | speed={speed:.2f} ep/s | elapsed={elapsed/60:.1f} min | ETA={eta_sec/60:.1f} min")
                    last_stat_t = now
                    last_stat_ep = ep_count

                # ===== 定期落盘 checkpoint =====
                if ep_count % CHECKPOINT_EVERY_EP == 0:
                    print(f"[CKPT] Saving checkpoint at ep={ep_count} ...")
                    maybe_checkpoint()
                    print(f"[CKPT] Saved latest to: {latest_json_path}")

        pbar.close()

    except KeyboardInterrupt:
        pbar.close()
        print("\n[WARN] Interrupted by user. Saving latest checkpoint...")
        maybe_checkpoint()
        print("[WARN] Latest checkpoint saved. You can resume by reading reward_records_latest.json")
        raise

    except Exception as e:
        pbar.close()
        print(f"\n[ERROR] Exception occurred: {repr(e)}")
        print("[ERROR] Saving latest checkpoint before raising...")
        maybe_checkpoint()
        print("[ERROR] Latest checkpoint saved.")
        raise

    # ===================== 汇总：better seeds =====================
    better_seeds_by_case = {}
    for case_id in range(CASE_START, CASE_END + 1):
        diffs = []
        for seed in range(SEED_START, SEED_END + 1):
            item = scores[case_id].get(seed, {})
            if "rl" not in item or "idm" not in item:
                continue
            delta = item["rl"] - item["idm"]
            if delta > 0:
                diffs.append({"seed": seed, "rl_reward": item["rl"], "idm_reward": item["idm"], "delta": delta})
        diffs.sort(key=lambda x: x["delta"], reverse=True)
        better_seeds_by_case[case_id] = diffs

    # ===================== 保存最终文件 =====================
    safe_write_json(final_json_path, records)
    safe_write_json(final_better_path, better_seeds_by_case)
    write_csv(final_csv_path, records)

    # 同步更新 latest（最终结果覆盖 latest）
    safe_write_json(latest_json_path, records)
    safe_write_json(latest_better_path, better_seeds_by_case)
    write_csv(latest_csv_path, records)

    # ===================== 控制台输出 Top10 =====================
    print("\n======== Summary: seeds where RL > IDM (top 10 by delta) ========")
    for case_id in range(CASE_START, CASE_END + 1):
        lst = better_seeds_by_case[case_id]
        top10 = lst[:10]
        if len(top10) < 10:
            print(f"Case {case_id:02d}: only found {len(top10)} seeds with RL > IDM (out of {SEED_END-SEED_START+1}).")
        else:
            print(f"Case {case_id:02d}: found {len(lst)} seeds with RL > IDM. Top10:")
        for item in top10:
            print(f"  seed={item['seed']:3d}  delta={item['delta']:+.4f}  RL={item['rl_reward']:.4f}  IDM={item['idm_reward']:.4f}")

    test_env_idm.close()
    test_env_rl.close()

    dt = time.time() - t0
    print("\nSaved FINAL:")
    print(f"  JSON records: {final_json_path}")
    print(f"  Better seeds: {final_better_path}")
    print(f"  CSV summary : {final_csv_path}")
    print("\nSaved LATEST:")
    print(f"  JSON latest:  {latest_json_path}")
    print(f"  Better latest:{latest_better_path}")
    print(f"  CSV latest:   {latest_csv_path}")
    print(f"\nTotal wall time: {dt/60:.1f} min")
