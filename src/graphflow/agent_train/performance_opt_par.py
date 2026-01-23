import os
import sys
import time
import json
import csv
import random
import numpy as np
import multiprocessing as mp

from stable_baselines3 import PPO
from train_agent_ppo import make_env
from compass_env.utils import REWARD_KEYS, init_reward_dict

# =========================
# 工具函数
# =========================
def set_global_seeds(seed: int):
    random.seed(seed)
    np.random.seed(seed)
    try:
        import torch
        torch.manual_seed(seed)
        if torch.cuda.is_available():
            torch.cuda.manual_seed_all(seed)
    except Exception:
        pass

def ensure_float_dict(d: dict):
    out = {}
    for k, v in d.items():
        if isinstance(v, (np.floating, np.float32, np.float64)):
            out[k] = float(v)
        elif isinstance(v, (np.integer, np.int32, np.int64)):
            out[k] = int(v)
        elif isinstance(v, (int, float)):
            out[k] = float(v)
        else:
            out[k] = v
    return out

def run_episode_idm(env, seed: int, case_id: int):
    set_global_seeds(seed)
    rd = init_reward_dict()
    obs, info = env.reset(seed=seed, options={"case_id": case_id})
    done = truncated = False
    steps = 0
    while not (done or truncated):
        obs, reward, done, truncated, info = env.step([0, 0])
        for k in REWARD_KEYS:
            rd[k] += float(info.get(k, 0.0))
        steps += 1
    return ensure_float_dict(rd), steps, bool(done), bool(truncated)

def run_episode_rl(env, model, seed: int, case_id: int, deterministic=True):
    set_global_seeds(seed)
    rd = init_reward_dict()
    obs, info = env.reset(seed=seed, options={"case_id": case_id})
    done = truncated = False
    steps = 0
    while not (done or truncated):
        action, _ = model.predict(obs, deterministic=deterministic)
        obs, reward, done, truncated, info = env.step(action)
        for k in REWARD_KEYS:
            rd[k] += float(info.get(k, 0.0))
        steps += 1
    return ensure_float_dict(rd), steps, bool(done), bool(truncated)

def safe_write_json(path: str, obj):
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
    os.replace(tmp, path)

def write_csv(path: str, flat_rows, header):
    tmp = path + ".tmp"
    with open(tmp, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(header)
        for row in flat_rows:
            w.writerow(row)
    os.replace(tmp, path)

# =========================
# Worker 进程主循环
# =========================
def worker_loop(algo: str,
                rank: int,
                task_q: mp.Queue,
                result_q: mp.Queue,
                model_path: str,
                deterministic: bool):
    """
    algo: "IDM" or "RL"
    rank: 用于 make_env 的唯一 rank（端口/目录等不冲突）
    task_q: 输入任务队列 (seed, case_id)；None 表示退出
    result_q: 输出结果队列
    """
    try:
        # 每个进程仅初始化一次 env/模型
        if algo == "IDM":
            env_config = {"case_num": 1, "test_mode": True, "auto_mode": True}
            env = make_env(rank, config=env_config, render_mode=None, verbose=False)()
            model = None
        else:
            env_config = {"case_num": 1, "test_mode": True, "auto_mode": False}
            env = make_env(rank, config=env_config, render_mode=None, verbose=False)()
            model = PPO.load(model_path, device="cpu")

        while True:
            task = task_q.get()
            if task is None:
                break
            seed, case_id = task

            t0 = time.time()
            if algo == "IDM":
                rd, steps, done, trunc = run_episode_idm(env, seed, case_id)
                total = float(rd.get("reward", 0.0))
            else:
                rd, steps, done, trunc = run_episode_rl(env, model, seed, case_id, deterministic=deterministic)
                total = float(rd.get("reward", 0.0))

            result_q.put({
                "algo": algo,
                "rank": rank,
                "seed": seed,
                "case_id": case_id,
                "steps": steps,
                "done": done,
                "truncated": trunc,
                "total_reward": total,
                "reward_dict": rd,
                "wall_s": time.time() - t0
            })

        try:
            env.close()
        except Exception:
            pass

    except Exception as e:
        # 把异常也丢回主进程，方便定位哪个 rank 崩了
        result_q.put({
            "algo": algo,
            "rank": rank,
            "error": repr(e)
        })

# =========================
# 主程序
# =========================
if __name__ == "__main__":
    mp.set_start_method("spawn", force=True)

    # ========= 参数 =========
    LOG_DIR = "./outputs/compass_transformer_ppo/"
    MODEL_PATH = os.path.join(LOG_DIR, "model_trans_128_case_001")

    OUT_DIR = os.path.join(LOG_DIR, "batch_eval_compare_parallel")
    os.makedirs(OUT_DIR, exist_ok=True)

    SEED_START, SEED_END = 0, 100   # inclusive
    CASE_START, CASE_END = 1, 28

    N_RL = 16
    N_IDM = 4
    # rank 不重叠：RL 0..7，IDM 8..15（你也可以换成 RL 0..7，IDM 17..24 之类）
    RL_RANK_BASE = 0
    IDM_RANK_BASE = RL_RANK_BASE + N_RL  # 8

    DETERMINISTIC = True

    SAVE_EVERY_PAIR = 50  # 每完成 N 个 (seed,case) pair 就保存一次 latest（防崩）

    # ========= 进度条 =========
    try:
        from tqdm import tqdm
        use_tqdm = True
    except ImportError:
        use_tqdm = False

    # ========= 任务准备 =========
    pairs = [(seed, case_id)
             for seed in range(SEED_START, SEED_END + 1)
             for case_id in range(CASE_START, CASE_END + 1)]
    total_pairs = len(pairs)                 # 101*28 = 2828
    total_eps = total_pairs * 2              # IDM + RL

    # ========= 队列 =========
    rl_q = mp.Queue()      # 或 mp.Queue(maxsize=0)
    idm_q = mp.Queue()

    res_q = mp.Queue()

    # 把所有任务放入两队列（RL/IDM 都要跑同样的 pair）
    for task in pairs:
        rl_q.put(task)
        idm_q.put(task)

    # 退出哨兵（每个 worker 一个 None）
    for _ in range(N_RL):
        rl_q.put(None)
    for _ in range(N_IDM):
        idm_q.put(None)

    # ========= 启动 worker =========
    procs = []
    for i in range(N_RL):
        rank = RL_RANK_BASE + i
        p = mp.Process(target=worker_loop, args=("RL", rank, rl_q, res_q, MODEL_PATH, DETERMINISTIC), daemon=True)
        p.start()
        procs.append(p)

    for i in range(N_IDM):
        rank = IDM_RANK_BASE + i
        p = mp.Process(target=worker_loop, args=("IDM", rank, idm_q, res_q, MODEL_PATH, DETERMINISTIC), daemon=True)
        p.start()
        procs.append(p)

    print(f"[INFO] Started workers: RL={N_RL} ranks {RL_RANK_BASE}..{RL_RANK_BASE+N_RL-1}, "
          f"IDM={N_IDM} ranks {IDM_RANK_BASE}..{IDM_RANK_BASE+N_IDM-1}")
    print(f"[INFO] Total pairs={total_pairs}, total episodes={total_eps}")
    print(f"[INFO] Output dir: {OUT_DIR}")

    # ========= 主进程汇总 =========
    # pending[(seed,case)] = {"RL": result, "IDM": result}
    pending = {}
    # 每条 episode 记录
    episode_records = []
    # 每个 case 的更优 seed 列表
    better_by_case = {case_id: [] for case_id in range(CASE_START, CASE_END + 1)}

    # 扁平 CSV 行（每个 episode 一行）
    csv_header = ["algo", "seed", "case_id", "rank", "steps", "done", "truncated", "total_reward", "wall_s"] + [f"r_{k}" for k in REWARD_KEYS]
    csv_rows = []

    # 进度条：用 “episode” 计数最直观
    if use_tqdm:
        pbar = tqdm(total=total_eps, ncols=110, desc="Episodes", unit="ep")
    else:
        pbar = None

    stamp = time.strftime("%Y%m%d_%H%M%S")
    latest_json = os.path.join(OUT_DIR, "latest_episode_records.json")
    latest_better = os.path.join(OUT_DIR, "latest_better_seeds.json")
    latest_csv = os.path.join(OUT_DIR, "latest_episode_records.csv")

    t0 = time.time()
    got_eps = 0
    got_pairs_done = 0

    # 用于速度估计
    last_stat_t = time.time()
    last_stat_eps = 0

    try:
        while got_eps < total_eps:
            msg = res_q.get()

            # worker 异常透传
            if "error" in msg:
                raise RuntimeError(f"Worker crashed: algo={msg.get('algo')} rank={msg.get('rank')} error={msg['error']}")

            algo = msg["algo"]
            seed = msg["seed"]
            case_id = msg["case_id"]

            episode_records.append(msg)

            # CSV 行
            rd = msg["reward_dict"]
            csv_rows.append([
                algo, seed, case_id, msg["rank"], msg["steps"], int(msg["done"]), int(msg["truncated"]),
                msg["total_reward"], msg["wall_s"]
            ] + [float(rd.get(k, 0.0)) for k in REWARD_KEYS])

            # pending merge
            key = (seed, case_id)
            pending.setdefault(key, {})
            pending[key][algo] = msg

            got_eps += 1
            if pbar:
                # postfix 展示 delta 需要等 RL & IDM 都到齐
                postfix = {"seed": seed, "case": case_id, "algo": algo, "R": f"{msg['total_reward']:.2f}"}
                if "RL" in pending[key] and "IDM" in pending[key]:
                    delta = pending[key]["RL"]["total_reward"] - pending[key]["IDM"]["total_reward"]
                    postfix["Δ"] = f"{delta:+.2f}"
                pbar.update(1)
                pbar.set_postfix(postfix)

            # 如果这个 pair 两边都到齐，更新 better_by_case
            if "RL" in pending[key] and "IDM" in pending[key]:
                rl_total = pending[key]["RL"]["total_reward"]
                idm_total = pending[key]["IDM"]["total_reward"]
                delta = rl_total - idm_total
                if delta > 0:
                    better_by_case[case_id].append({"seed": seed, "delta": delta, "rl": rl_total, "idm": idm_total})
                got_pairs_done += 1
                # 可以释放内存（尤其是 reward_dict 很大时）
                del pending[key]

                # 定期保存
                if got_pairs_done % SAVE_EVERY_PAIR == 0:
                    # 每个 case 的 better 排序
                    for cc in better_by_case:
                        better_by_case[cc].sort(key=lambda x: x["delta"], reverse=True)
                    safe_write_json(latest_json, episode_records)
                    safe_write_json(latest_better, better_by_case)
                    write_csv(latest_csv, csv_rows, csv_header)

            # 定期打印速度/ETA
            if got_eps % 200 == 0:
                now = time.time()
                dt = now - last_stat_t
                deps = got_eps - last_stat_eps
                speed = deps / dt if dt > 1e-6 else float("inf")
                remain = total_eps - got_eps
                eta_min = (remain / speed) / 60.0 if speed > 1e-6 else float("inf")
                elapsed_min = (now - t0) / 60.0
                print(f"[STAT] {got_eps}/{total_eps} ep | {got_pairs_done}/{total_pairs} pairs merged | "
                      f"speed={speed:.2f} ep/s | elapsed={elapsed_min:.1f} min | ETA={eta_min:.1f} min")
                last_stat_t, last_stat_eps = now, got_eps

        if pbar:
            pbar.close()

    finally:
        # 收尾：保证子进程退出
        for p in procs:
            p.join(timeout=2.0)

    # 最终排序 & 保存
    for cc in better_by_case:
        better_by_case[cc].sort(key=lambda x: x["delta"], reverse=True)

    final_json = os.path.join(OUT_DIR, f"episode_records_{stamp}.json")
    final_better = os.path.join(OUT_DIR, f"better_seeds_{stamp}.json")
    final_csv = os.path.join(OUT_DIR, f"episode_records_{stamp}.csv")

    safe_write_json(final_json, episode_records)
    safe_write_json(final_better, better_by_case)
    write_csv(final_csv, csv_rows, csv_header)

    dt = time.time() - t0
    print(f"\n[INFO] Done. wall={dt/3600:.2f} h, episodes={total_eps}, pairs={total_pairs}")
    print(f"[INFO] Saved: {final_json}")
    print(f"[INFO] Saved: {final_better}")
    print(f"[INFO] Saved: {final_csv}")

    # 控制台输出：每个 case top10
    print("\n======== Top seeds where RL > IDM (top 10 by delta) ========")
    for cc in range(CASE_START, CASE_END + 1):
        lst = better_by_case[cc]
        top10 = lst[:10]
        if len(top10) < 10:
            print(f"Case {cc:02d}: only {len(top10)} seeds with RL>IDM")
        else:
            print(f"Case {cc:02d}: found {len(lst)} seeds with RL>IDM. Top10:")
        for x in top10:
            print(f"  seed={x['seed']:3d}  Δ={x['delta']:+.4f}  RL={x['rl']:.4f}  IDM={x['idm']:.4f}")
