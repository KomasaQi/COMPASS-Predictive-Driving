from __future__ import annotations

import imageio
import os
import numpy as np
import math
from collections import OrderedDict
import traci
from traci import constants as tc
import matplotlib.pyplot as plt
from compass_env.envs.common.trailer_mei import compute_real_time_metrics_fast as calc_mei
import pathlib
import random

def xy2dist(path: np.ndarray) -> np.ndarray:
    """_summary_
    
    # 计算路径上每个点到起点的距离。

    参数:
    path (np.ndarray): 路径上的点坐标,形状为 (n, 2),其中 n 是路径上的点的数量。

    返回:
    np.ndarray: 每个点到起点的距离,形状为 (n,)。
    """
    # 计算每个点到起点的距离
    dist = np.sqrt(np.sum(np.diff(path, axis=0)**2, axis=1))
    # 累加距离,得到每个点到起点的距离
    dist = np.insert(np.cumsum(dist), 0, 0)
    return dist


def convert_sumo_angle(angle: float) -> float:
    """_summary_
    
    # 将 SUMO 角度转换为 Compass 角度。
    
    参数:
    angle (float): SUMO 角度,范围为 [0, 360] deg
    
    返回:
    float: Compass 角度,范围为 [-pi, pi]。
    """
    # 将 SUMO 角度转换为 Compass 角度
    compass_angle = -math.radians(angle) + math.pi/2
    # 确保 Compass 角度在 [-pi, pi] 范围内
    if compass_angle > math.pi:
        compass_angle -= 2 * math.pi
    elif compass_angle < -math.pi:
        compass_angle += 2 * math.pi
    return compass_angle


def embed_signal_state(signal: int) -> np.ndarray:
    """_summary_
    
    # 将车辆信号灯状态编码为 one-hot 向量。
    
    参数:
    signal (int): 车辆信号灯状态,0 表示红灯,1 表示绿灯,2 表示黄灯。
    
    返回:
    np.ndarray: 车辆信号灯状态的 one-hot 向量,形状为 (3,)。
    """
    # 将车辆信号灯状态编码为 one-hot 向量
    
    light_state = np.zeros(3)
    if (bin(signal) and 0b001) > 0:
        light_state[0] = 1
    if (bin(signal) and 0b010) > 0:
        light_state[1] = 1
    if (bin(signal) and 0b100) > 0:
        light_state[2] = 1
    return light_state

def descern_mission(mission: str) -> np.ndarray:
    """_summary_
    
    # 从任务描述中提取任务类型。
    
    参数:
    mission (str): 任务描述,例如 "exit_5"。
    
    返回:
    mission_type (np.ndarray): 任务类型 [pass/cruise, merge, exit]。
    """
    # 从任务描述中提取任务类型
    mission_type = np.zeros(3)
    if 'pass' in mission or 'cruise' in mission:
        mission_type[0] = 1
    elif 'merge' in mission:
        mission_type[1] = 1
    elif 'exit' in mission:
        mission_type[2] = 1
    return mission_type

def encode_vehicle_class(vclass: str) -> float:
    """_summary_
    
    # 将车辆类型编码为浮点数。
    
    参数:
    vclass (str): 车辆类型,例如 "passenger"。
    
    返回:
    float: 车辆类型的编码,例如 0.0 表示 "passenger"。
    """
    # 将车辆类型编码为浮点数
    if vclass == "private":
        return -1.0
    elif vclass == "bus":
        return -0.5
    elif vclass == "truck":
        return 0.0
    elif vclass == "trailer":
        return 1.0
    else:
        return 0.0
    
def encode_intention(veh_id: str) -> np.ndarray:
    """_summary_
    
    # 将车辆意图编码为 one-hot 向量。
    
    参数:
    veh_id (str): 车辆 ID,例如 "flow_exit.109"。
    
    返回:
    np.ndarray: 车辆意图的 one-hot 向量,形状为 (3,)。
    """
    # 将车辆意图编码为 one-hot 向量
    # 从任务描述中提取任务类型
    intention = np.zeros(3)
    if 'main' in veh_id:
        intention[0] = 1
    elif 'merge' in veh_id:
        intention[1] = 1
    elif 'exit' in veh_id:
        intention[2] = 1

    return intention

def normalize_speed(speed: float) -> float:
    """_summary_
    
    # 归一化速度到接近 [-1, 1] 范围。
    
    参数:
    speed (float): 速度值,单位为 m/s。
    
    返回:
    float: 归一化后的速度值,范围接近 [-1, 1]。
    """
    # 归一化速度到接近 [-1, 1] 范围
    return speed / 20 - 1

def normalize_bbox(length: float, width: float) -> np.ndarray:
    """_summary_
    
    # 归一化车辆长度和宽度到接近 [-1, 1] 范围。
    
    参数:
    length (float): 车辆长度,单位为 m。
    width (float): 车辆宽度,单位为 m。
    
    返回:
    np.ndarray: 归一化后的车辆长度和宽度,形状为 (2,)。
    """
    # 归一化车辆长度和宽度到 [-1, 1] 范围
    return length / 5 - 2, width - 2


def compress_distance(distance: float, scale_factor: float = 50.0) -> float:
    """_summary_
    
    # 压缩距离到 [-1, 1] 范围。
    
    参数:
    distance (float): 距离值,单位为 m。
    scale_factor (float, optional): 压缩因子,默认值为 50.0。
    
    返回:
    float: 压缩后的距离值,范围为 [-1, 1]。
    """
    # 使用sigmoid函数压缩距离到 [-1, 1] 范围
    compressed_dist = 1 / (1 + np.exp(-distance/scale_factor))*2 - 1
    
    return compressed_dist


def embed_vehicle_type(vtype: str) -> int:
    """_summary_
    将车辆类别映射到数字
    Inputs:
        vtype (string): 
    Returns:
        vtype_index (int): 将车辆类别到数字
    """
    if "eco" in vtype:
        vtype_index = 1
    elif "sedan" in vtype:
        vtype_index = 2
    elif "sport" in vtype:
        vtype_index = 3
    elif "suv" in vtype:
        vtype_index = 4
    elif "van" in vtype:
        vtype_index = 5
    elif "bus" in vtype:
        vtype_index = 6
    elif "light" in vtype:
        vtype_index = 7 
    elif "medium" in vtype:
        vtype_index = 8
    elif "heavy" in vtype:
        vtype_index = 9
    elif "concrete" in vtype:
        vtype_index = 10
    elif "standard" in vtype:
        vtype_index = 11
    elif "long" in vtype:
        vtype_index = 12    
    elif "double" in vtype:
        vtype_index = 13
    elif "tank" in vtype:
        vtype_index = 0
    else:
        vtype_index = -1
        
    return vtype_index



class Track:
    """
    单车历史轨迹缓存（环形缓冲区 Circular Buffer）

    设计目标:
    1) 固定长度 history_length:不会因时间增长而扩展内存
    2) O(1) 写入:无需数组整体移动
    3) 支持“补0帧”:当车辆仍在 TTL（你文中写 TTC,我按 TTL 理解）窗口内但本步未被记录,
       也要把历史推进一帧全0,从而保证时间步间隔严格一致

    关键点:将“真实观测到车辆”和“为了保持时间步一致性而补0”区分开
    - last_real_seen:上一次真实观测到该车的 step（用于 TTL 淘汰）
    - last_filled_step:缓冲区最近推进到的 step（真实 or 补0都算,用于补齐缺失 step）
    """
    __slots__ = (
        "buf", "ptr", "filled", "history_length",
        "last_real_seen", "last_filled_step"
    )

    def __init__(self, history_length: int, feature_dim: int, dtype=np.float32):
        self.history_length = int(history_length)
        self.buf = np.zeros((self.history_length, int(feature_dim)), dtype=dtype)

        # 指向“下一次写入”的行索引
        self.ptr = 0

        # 已写入的有效步数（<= history_length）
        self.filled = 0

        # 上次“真实观测”到的 step；用于 TTL 淘汰
        self.last_real_seen = -1

        # 上次缓冲区推进到的 step（真实/补0都算）；用于严格补齐 step 间隔
        self.last_filled_step = -1

    def push(self, feat: np.ndarray, step: int, real: bool):
        """
        写入一帧特征到环形缓冲区

        :param feat: shape=(feature_dim,)
        :param step: 当前 step 索引
        :param real: True=真实观测（更新 last_real_seen）,False=补0帧（不更新 last_real_seen）
        """
        self.buf[self.ptr] = feat
        self.ptr = (self.ptr + 1) % self.history_length
        self.filled = min(self.filled + 1, self.history_length)

        if real:
            self.last_real_seen = step

        self.last_filled_step = step

    def get_time_order(self) -> np.ndarray:
        """
        按时间顺序（从早到晚）返回历史序列
        返回 shape=(filled_or_H, feature_dim)

        注意:若 filled < history_length,仅返回已填充部分；外部负责做 padding（左侧补0）
        """
        if self.filled < self.history_length:
            return self.buf[:self.filled]

        # 缓冲区满:ptr 指向下一写入位置；ptr 之后是“最早的”,ptr-1 是“最新的”
        return np.concatenate([self.buf[self.ptr:], self.buf[:self.ptr]], axis=0)


class NeighborHistoryObs:
    """
    邻车历史观测构建器（面向 Gym/SUMO world model）

    功能:
    1) 输入 ego_vars 与 veh_vars（通常来自订阅结果）:
       - ego_vars: traci.vehicle.getSubscriptionResults(ego_id)
       - veh_vars: traci.vehicle.getContextSubscriptionResults(ego_id)
    2) 从 veh_vars 中筛选距离 ego 最近的 V 辆（vehicle_counts）
    3) 对“被记录到”的车辆写入真实观测帧
    4) 对“仍在 TTL 内但本步未被记录到”的车辆补0帧,保证时间间隔严格一致
    5) TTL + LRU 淘汰,保证缓存规模受控
    6) 输出固定 shape 的历史观测张量:obs shape=(V, F, H)

    重要语义说明:
    - 这里“本步记录到车辆”默认指:该车进入 top-V（selected）集合
      若你希望“只要在观测半径内（context 返回）就算记录到”,可将 updated_real
      的定义改为 context 内全部车辆（见 step_build_obs 里注释点）。
      
    """

    veh_feat_var = {
        "presence": 0,
        "x": 1,
        "y": 2,
        "vx": 3,
        "vy": 4,
        "cos_h": 5,
        "sin_h": 6,
        "lane_index": 7,
        "lane_dev": 8,
        "on_main_road": 9,
        "speed_lim": 10,
        "max_speed": 11,
        "left": 12,
        "right": 13,
        "brake": 14,
        "length": 15,
        "width": 16,
        "vclass": 17,
        "main": 18,
        "merge": 19,
        "exit": 20,
        "mei": 21,
        "rttc_1": 22,
        "shortestdist_1": 23,
        "vtype": 24,
    }
    
    def __init__(
        self,
        obs_radius: float,
        vehicle_counts: int,
        history_length: int,
        feature_dim: int = 25,
        tracking_dict_len: int = 50,
        ttl: int = 5,
        relative_pos: bool = True,
        ttc_inv_lim: float = 2.0,
        verbose: int = 0,
        ego_id:str = 't_0'
    ):
        """
        :param obs_radius: 观测半径（米）,这里只用于语义描述；真正筛选通常已由 context subscription 完成
        :param vehicle_counts: 输出的邻车数 V（取最近 V 辆）
        :param history_length: 历史长度 H
        :param feature_dim: 特征维度 F（默认 7: presence, x, y, vx, vy, sin, cos）
        :param tracking_dict_len: 缓存容量（最大同时维护的车辆数）
        :param ttl: TTL（步数）。超过 ttl 步未被真实观测到的车辆将被淘汰
        :param relative_pos: 是否使用相对自车的位置（默认 True）
        :param ttc_inv_lim: TTC 倒数限制（默认 2.0）
        :param verbose:  verbose 等级（默认 0） 1: 正常打印 2: Debug
        :param ego_id: 自车ID
        """
        self.R = float(obs_radius)
        self.V = int(vehicle_counts)
        self.H = int(history_length)
        self.F = int(feature_dim)
        self.ttl = int(ttl)
        self.cache_cap = tracking_dict_len
        self.ego_vars = None
        self.veh_vars = None
        self.relative_pos = relative_pos
        self.til = ttc_inv_lim
        self.verbose = 0
        self.ego_id = ego_id

        # LRU:OrderedDict 末尾为最近使用
        self.tracks: "OrderedDict[str, Track]" = OrderedDict()

    def _get_or_create(self, vid: str) -> Track:
        """
        获取或创建车辆轨迹缓存；并刷新 LRU（移至末尾）
        """
        trk = self.tracks.get(vid)
        if trk is None:
            trk = Track(self.H, self.F)
            self.tracks[vid] = trk
        else:
            self.tracks.move_to_end(vid, last=True)
        return trk

    def _feat_from_vars(self, vars: dict, veh_id: str) -> np.ndarray:
        """
        将 SUMO 原始状态 -> 23 维特征向量

        说明:
        - presence:1.0 表示该帧为有效观测:补0帧会全0,因此 presence=0
        - vx, vy:将 speed 按 angle 分解；注意 SUMO angle 坐标系可能与你的数学坐标系不同,
          若方向不对,请自行校验并调整（例如交换 sin/cos 或符号）。
        * **他车状态**: 
            - 是否存在                      +1   0: `presence`
            - (相对)位置                    +2   1:`x` 2:`y`
            - 速度(纵向归一化+横向)          +2   3:`vx` 4:`vy`
            - (相对)航向角                  +2   5:`cos_h` 6:`sin_h`
            - 车道索引                      +1   7:`lane_index`
            - 车道偏移                      +1   8:`lane_dev`
            - 位于匝道/主路                 +1   9:`on_main_road`
            - 当前限速                      +1  10:`speed_lim`
            - 最高车速                      +1  11:`max_speed`
            - 灯语状态                      +3  12:`left` 13:`right` 14:`brake`
            - 车辆长度                      +1  15:`length`
            - 车辆宽度                      +1  16:`width`
            - 车辆类型                      +1  17:`vclass`
            - 导航意图(one-hot)             +3  18:`main` 19:`merge` 20:`exit`
            - 对自车的MEI                   +1  21:`mei`
            - 对自车的1/RTTC                +1  22:`rttc_1`
            - 1/与自车的最近距离             +1  23:`shortestdist_1`
            - vtype车辆类别                 +1  24:`vtype`
            特征维度: 25
        所有车辆在编码时加入自车/车辆类型可学习嵌入,维度为 dim_clsmb
          
          
        """
        presense = 1.0
        ex, ey = self.ego_vars[tc.VAR_POSITION]
        x, y = vars[tc.VAR_POSITION]
        ego_spd = self.ego_vars[tc.VAR_SPEED]
        ego_angle = convert_sumo_angle(self.ego_vars[tc.VAR_ANGLE])
        ego_length = self.ego_vars[tc.VAR_LENGTH]
        ego_width = self.ego_vars[tc.VAR_WIDTH]
        ang = convert_sumo_angle(vars[tc.VAR_ANGLE])
        if self.relative_pos:
            x, y = x - ex, y - ey
            ang = ang - ego_angle
            if ang > math.pi:
                ang -= 2 * math.pi
            elif ang < -math.pi:
                ang += 2 * math.pi
            ex, ey = 0.0, 0.0
            ego_angle = 0.0
            
            
        vx = vars[tc.VAR_SPEED]
        vy = vars[tc.VAR_SPEED_LAT]
        signal_state = embed_signal_state(vars[tc.VAR_SIGNALS])
        length, width = normalize_bbox(vars[tc.VAR_LENGTH], vars[tc.VAR_WIDTH])
        intention = encode_intention(veh_id)
        
        act, v_closest, Shortest_D, InDepth, mei, rttc, dtc, v_norm = calc_mei(
            ex, ey, ego_spd, ego_angle, ego_length, ego_width,
            x, y, vx, ang, vars[tc.VAR_LENGTH], vars[tc.VAR_WIDTH]
        )
        
        if np.isnan(rttc):
            rttc = 1e3
        if np.isnan(mei):
            mei = -self.til
        if np.isnan(Shortest_D):
            Shortest_D = 1e3
        
        if self.verbose == 2:
            print(f"Calculate SSMs with vehicle: {veh_id}")
            print(f"ACT: {act:.4f} s")
            print(f"v_closest: {v_closest:.4f} m/s")
            print(f"Shortest_D: {Shortest_D:.4f} m")

            print(f"RTTC: {rttc:.4f} s")
            print(f"DTC: {dtc:.4f} m")
            print(f"v_norm: {v_norm:.4f} m/s")

            print(f"InDepth: {InDepth:.4f} m")
            print(f"MEI: {mei:.4f} m/s")
        
        return np.array(
            [presense,                                          # 0: presence
             compress_distance(x), compress_distance(y),        # 1:x 2:y
             normalize_speed(vx), vy,                           # 3:vx 4:vy
             math.cos(ang), math.sin(ang),                      # 5:cos_h 6:sin_h
             vars[tc.VAR_LANE_INDEX],                           # 7:lane_index
             vars[tc.VAR_LANEPOSITION_LAT],                     # 8:lane_dev
             1.0 if vars[tc.VAR_ALLOWED_SPEED] > 15 else 0.0,   # 9:on_main_road
             normalize_speed(vars[tc.VAR_ALLOWED_SPEED]),       # 10:speed_lim
             normalize_speed(vars[tc.VAR_MAXSPEED]),            # 11:max_speed
             signal_state[0], signal_state[1], signal_state[2], # 12:left 13:right 14:brake
             length, width,                                     # 15:length 16:width
             encode_vehicle_class(vars[tc.VAR_VEHICLECLASS]),   # 17:vclass
             intention[0], intention[1], intention[2],          # 18:mian 19:merge 20:exit
             mei,                                               # 21:mei
             np.clip(1/rttc, -self.til, self.til),              # 22:rttc_1
             np.clip(1/Shortest_D*0.2, 0, self.til),            # 23:shortestdist_1
             embed_vehicle_type(vars[tc.VAR_TYPE]),             # 24:vtype
             ],
            dtype=np.float32)
        
        
        

    def step_build_obs(
        self,
        step_idx: int,
        ego_vars: dict,
        veh_vars: dict,
    ) -> np.ndarray:
        """
        每步构建观测张量:shape=(V, F, H)

        :param step_idx: 当前仿真步索引（整数）
        :param ego_vars: ego 的订阅结果 dict（必须含 VAR_POSITION, VAR_SPEED, VAR_ANGLE）
        :param veh_vars: ego 周边车辆的 context subscription 结果 dict
                        格式:{vid: {varID: value}}
                        必须包含:VAR_POSITION, VAR_SPEED, VAR_ANGLE
        :return: obs (V, F, H)
        """
        self.ego_vars = ego_vars
        self.veh_vars = veh_vars
        # -----------------------
        # 1) 读取 ego 状态
        # -----------------------
        ego_pos = ego_vars[tc.VAR_POSITION]
        ex, ey = ego_pos

        # -----------------------
        # 2) 收集候选邻车并按距离排序,取最近 V 辆
        # -----------------------
        candidates = []
        for vid, vars_ in veh_vars.items():
            if vid == self.ego_id:
                continue
            x, y = vars_[tc.VAR_POSITION]
            dist = math.hypot(x - ex, y - ey)
            candidates.append((dist, vid, vars_))

        candidates.sort(key=lambda t: t[0])
        selected = candidates[:self.V]  # 最终输出邻车集合

        # -----------------------
        # 3) 写入“真实观测帧”
        #    默认:仅 selected 被视为“本步记录到”
        # -----------------------
        updated_real = set()

        # for dist, vid, vars_ in selected:
        #     feat = self._feat_from_vars(
        #         vars_[tc.VAR_POSITION],
        #         vars_[tc.VAR_SPEED],
        #         vars_[tc.VAR_ANGLE]
        #     )
        #     self._get_or_create(vid).push(feat, step_idx, real=True)
        #     updated_real.add(vid)

        # 如果你希望“只要在观测半径内（context 返回）就算记录到”,
        # 请改为下面这种（并注释掉上面 selected 的 updated_real 逻辑）:
        #
        for vid, vars_ in veh_vars.items():
            if vid == self.ego_id:
                continue
            feat = self._feat_from_vars(vars=vars_, veh_id=vid)
            self._get_or_create(vid).push(feat, step_idx, real=True)
            updated_real.add(vid)

        # -----------------------
        # 4) 对仍在 TTL 内但本步未“真实更新”的车辆补0帧
        #    目的:保证时间间隔严格一致,尤其是车辆再次被选中时
        #
        #    关键约束:补0不能影响 TTL 淘汰,因此只推进 last_filled_step,不更新 last_real_seen
        # -----------------------
        zero_feat = np.zeros((self.F,), dtype=np.float32)

        # 注意:遍历时用 list(...) 防止遍历过程中 LRU move_to_end 导致迭代异常
        for vid, trk in list(self.tracks.items()):

            # 本步已经真实更新的,跳过补0
            if vid in updated_real:
                continue

            # 从未真实见过（一般不应发生）,跳过
            if trk.last_real_seen < 0:
                continue

            # 仍在 TTL 内才补0；超过 TTL 就不补,由淘汰逻辑删除
            if (step_idx - trk.last_real_seen) <= self.ttl:
                # 只补到 last_real_seen + ttl（TTL 之后不再补）
                target_step = min(step_idx, trk.last_real_seen + self.ttl)

                # 若存在 step 不连续（例如一次推进多步）,用 while 补齐每个缺失 step
                while trk.last_filled_step < target_step:
                    trk.push(zero_feat, trk.last_filled_step + 1, real=False)

        # -----------------------
        # 5) 淘汰过期 track（TTL）+ LRU 超容量淘汰
        # -----------------------
        self._evict(step_idx)

        # -----------------------
        # 6) 组装最终 obs:shape=(V, F, H)
        # -----------------------
        obs = np.zeros((self.V, self.H, self.F), dtype=np.float32)

        for i, (dist, vid, _) in enumerate(selected):
            # selected 中车辆应当存在于 tracks（刚 real push 过）,但做一下防御
            trk = self.tracks.get(vid)
            if trk is None:
                continue

            hist = trk.get_time_order()  # (filled or H, F)

            # 未填满 H 的情况,左侧补0,保证长度 H
            if trk.filled < self.H:
                pad = np.zeros((self.H - trk.filled, self.F), dtype=np.float32)
                hist_full = np.vstack([pad, hist])  # (H, F)
            else:
                hist_full = hist  # (H, F)

            obs[i] = hist_full  # (H, F)

        return obs, selected  # (V, H, F)

    def _evict(self, step_idx: int):
        """
        淘汰策略:
        1) TTL 淘汰:使用 last_real_seen 判断（非常关键！补0不能影响 TTL）
        2) 容量淘汰:LRU,超过 cache_cap 则弹出最久未使用的

        :param step_idx: 当前 step
        :param ego_id: 自车 id（如果 include_ego_in_tracks=True,可选择保护 ego 不被淘汰）
        """
        # 1) TTL 淘汰:按 last_real_seen 判断是否“超过 ttl 未真实观测”
        to_del = []
        for vid, trk in self.tracks.items():

            if (step_idx - trk.last_real_seen) > self.ttl:
                to_del.append(vid)

        for vid in to_del:
            self.tracks.pop(vid, None)

        # 2) LRU 容量淘汰:弹出最久未使用的（OrderedDict 头部）
        while len(self.tracks) > self.cache_cap:
            vid, trk = self.tracks.popitem(last=False)






def vis_matrix(matrix: np.ndarray, cmap: str = 'viridis', save_path: str = None, figure_size: tuple = (8, 6)):
    """
    绘制无额外标注的2D矩阵热力图（仅显示热力图本身）
    :param matrix: 2维numpy数组（必须是2D,否则会报错）
    :param cmap: 颜色映射方案,可选:viridis, jet, hot, cool, gray等
    :param save_path: 保存图片的路径（如'heatmap.png'）,为None则直接显示
    """
    # 校验输入:确保是2D数组
    if matrix.ndim != 2:
        raise ValueError(f"输入必须是2维数组,当前维度:{matrix.ndim}")
    
    # 创建画布（可调整figsize控制图片大小）
    plt.figure(figsize=figure_size)
    
    # 绘制热力图:关闭坐标轴、去掉刻度和标签
    ax = plt.gca()  # 获取当前坐标轴对象
    im = ax.imshow(matrix, cmap=cmap)
    
    # 核心:关闭所有额外标注
    ax.axis('off')  # 完全关闭坐标轴（包括边框、刻度、标签）
    ax.set_xticks([])  # 清空x轴刻度
    ax.set_yticks([])  # 清空y轴刻度
    plt.tight_layout()  # 紧凑布局,去掉多余空白
    
    # 保存或显示图片
    if save_path:
        # bbox_inches='tight' 去掉图片边缘空白,pad_inches=0 进一步压缩
        plt.savefig(save_path, bbox_inches='tight', pad_inches=0, dpi=150)
        print(f"热力图已保存至:{save_path}")
    else:
        plt.show()
    
    # 清理画布,避免内存占用
    plt.close()




def get_state_files(folder_path):
    """
    读取指定文件夹中所有以.state.xml.gz结尾的文件,返回完整路径列表
    
    Args:
        folder_path (str): 目标文件夹路径（相对/绝对路径均可）
    
    Returns:
        list: 符合条件的文件完整路径列表（pathlib.Path对象）
    """
    # 将路径转为Path对象,自动处理跨平台路径分隔符
    folder = pathlib.Path(folder_path)
    
    # 检查文件夹是否存在
    if not folder.is_dir():
        print(f"错误:文件夹 {folder_path} 不存在！")
        return []
    
    # 递归/非递归查找所有以.state.xml.gz结尾的文件
    # glob("*.state.xml.gz"):仅当前文件夹
    # glob("**/*.state.xml.gz"):递归子文件夹（如需递归则用这个）
    state_files = list(folder.glob("*.state.xml.gz"))
    
    # 可选:转为字符串路径（如果需要字符串而非Path对象）
    # state_files = [str(file) for file in state_files]
    
    print(f"找到 {len(state_files)} 个.state.xml.gz文件")
    return state_files

    # # ------------------- 调用示例 -------------------
    # # 1. 指定目标文件夹（替换为你的实际路径）
    # target_folder = "./compass_env/levels"  # 相对路径

    # # 2. 获取符合条件的文件列表
    # state_file_list = get_state_files(target_folder)

    # # 3. 随机选取一个文件（处理空列表情况）
    # if state_file_list:
    #     # 随机选一个
    #     random_file = random.choice(state_file_list)
    #     # 输出结果（Path对象可直接转字符串）
    #     print(f"随机选中的文件:{random_file}")
    #     # 如果需要仅文件名（不含路径）:
    #     print(f"仅文件名:{random_file.name}")
    # else:
    #     print("未找到任何.state.xml.gz文件！")
    
    
def get_lane_change_mode_bin(lc_cfg: dict = None) -> int:
    """
    获取车辆的车道变更模式二进制表示
    车道变换模型区分了四种变换车道的原因:

    战略性（变道以继续行驶路线）
    合作性（为允许其他车辆变道而进行的变道）
    提速（其他车道允许更快行驶）
    靠右行驶的义务
    在每个模拟步骤中,车道变换模型会计算一个内部请求,以决定变换车道还是保持在当前车道。

    如果外部车道变换指令（0x13）与内部请求存在冲突,将通过车辆车道变换模式的当前值来解决。
    给定的整数被解释为一个位集（bit0是最低有效位）,包含以下字段:

    bit1,bit0:  00 = 不做策略变更；
                01 = 若与TraCI请求不冲突,则进行策略变更；
                10 = 即使要推翻TraCI请求,也要进行策略变更
                
    bit3,bit2:  00 = 不进行协作更改；
                01 = 若与TraCI请求不冲突,则进行协作更改；
                10 = 即使覆盖TraCI请求,也要进行协作更改
                
    bit5,bit4:  00 = 不进行速度增益更改；
                01 = 若与TraCI请求不冲突,则进行速度增益更改；
                10 = 即使要覆盖TraCI请求,也要进行速度增益更改
                
    bit7,bit6:  00 = 不进行右车道变更；
                01 = 若与TraCI请求不冲突,则进行右车道变更；
                10 = 即使要覆盖TraCI请求,也要进行右车道变更
                
    bit9,bit8:  00 = 遵循TraCI请求时不考虑其他驾驶员,调整速度以完成请求 
                01 = 遵循TraCI请求时避免即时碰撞,调整速度以完成请求 
                10 = 变道时考虑其他车辆的速度/制动间隙,调整速度以完成请求 
                11 = 变道时考虑其他车辆的速度/制动间隙,不调整速度
                
    bit11,bit10:00 = 不进行子车道变更；
                01 = 若与TraCI请求不冲突,则进行子车道变更；
                10 = 即使要覆盖TraCI请求,也要进行子车道变更
    """
    # 定义默认配置及合法取值范围
    default_config = {
        "strategic": 1,           # 合法值: 0/1/2 （0 = 不做策略变更；1 = 若与TraCI请求不冲突,则进行策略变更；2 = 即使要推翻TraCI请求,也要进行策略变更）
        "cooperative": 1,         # 合法值: 0/1/2 （0 = 不进行协作更改；1 = 若与TraCI请求不冲突,则进行协作更改；2 = 即使覆盖TraCI请求,也要进行协作更改）
        "speed_gain": 1,          # 合法值: 0/1/2 （0 = 不进行速度增益更改；1 = 若与TraCI请求不冲突,则进行速度增益更改；2 = 即使要覆盖TraCI请求,也要进行速度增益更改）
        "keep_right": 1,          # 合法值: 0/1/2 （0 = 不进行右车道变更；1 = 若与TraCI请求不冲突,则进行右车道变更；2 = 即使要覆盖TraCI请求,也要进行右车道变更）
        "collision": 1,           # 合法值: 0/1/2/3 （0 = 遵循TraCI请求时不考虑其他驾驶员,调整速度以完成请求；
                                  #                  1 = 遵循TraCI请求时避免即时碰撞,调整速度以完成请求；
                                  #                  2 = 变道时考虑其他车辆的速度/制动间隙,调整速度以完成请求；
                                  #                  3 = 变道时考虑其他车辆的速度/制动间隙,不调整速度）
        "sub_lane": 1,            # 合法值: 0/1/2 （0 = 不进行子车道变更；1 = 若与TraCI请求不冲突,则进行子车道变更；2 = 即使要覆盖TraCI请求,也要进行子车道变更）
    }
    # 配置项的合法取值范围映射
    valid_ranges = {
        "strategic": (0, 1, 2),
        "cooperative": (0, 1, 2),
        "speed_gain": (0, 1, 2),
        "keep_right": (0, 1, 2),
        "collision": (0, 1, 2, 3),
        "sub_lane": (0, 1, 2),
    }

    # 合并用户配置（替换冗余的深度更新）
    lc_config = default_config.copy()
    if lc_cfg is not None:
        # 仅更新存在于默认配置中的键，避免传入无关键导致错误
        for k, v in lc_cfg.items():
            if k in lc_config:
                lc_config[k] = v

    # 校验每个配置项的取值是否合法
    for key, value in lc_config.items():
        if value not in valid_ranges[key]:
            raise ValueError(
                f"配置项 {key} 的值 {value} 不合法！合法取值为: {valid_ranges[key]}"
            )
    
    # 核心位运算逻辑（原逻辑正确，保留）
    lc_mode_bin = (
        (lc_config["strategic"] << 0) |
        (lc_config["cooperative"] << 2) |
        (lc_config["speed_gain"] << 4) |
        (lc_config["keep_right"] << 6) |
        (lc_config["collision"] << 8) |
        (lc_config["sub_lane"] << 10)
    )
    
    return lc_mode_bin
    
    
def get_speed_mode_bin(spd_cfg: dict = None) -> int:
    """
    获取车辆的速度模式二进制表示
    速度变换模型区分了四种变换车道的原因:
    setSpeedMode 说明
    bit0: 考虑安全速度
    bit1: 考虑最大加速度
    bit2: 考虑最大减速度
    bit3: 考虑交叉口内路权(适用于还没进入交叉口的敌对车辆)
    bit4: 急刹车以避免通过红灯
    bit5: 忽略交叉口内路权(适用于已进入交叉口的敌对车辆)
    bit6: 忽略速度限制
    """
    # 定义默认配置及合法取值范围
    speed_config = {
        "consider_safe_speed": True,              # False = 不考虑安全速度；True = 考虑安全速度
        "consider_max_accel": True,               # False = 不考虑最大加速度；True = 考虑最大加速度
        "consider_max_decel": True,               # False = 不考虑最大减速度；True = 考虑最大减速度
        "consider_intersection_right_out": True,  # False = 不考虑交叉口外车辆路权；True = 考虑交叉口外车辆路权
        "brake_hard_before_red_light": True,      # False = 不急刹车以避免通过红灯；True = 急刹车以避免通过红灯
        "ignore_intersection_right_in": False,    # False = 不忽略交叉口内车辆路权；True = 忽略交叉口内车辆路权
        "ignore_speed_limit": False,              # False = 不忽略速度限制；True = 忽略速度限制
    }
    if spd_cfg is not None:
        # 仅更新存在于默认配置中的键，避免传入无关键导致错误
        for k, v in spd_cfg.items():
            if k in speed_config:
                speed_config[k] = v
    # 核心位运算逻辑（原逻辑正确，保留）
    spd_mode_bin = (
        (int(speed_config["consider_safe_speed"]) << 0) |
        (int(speed_config["consider_max_accel"]) << 1) |
        (int(speed_config["consider_max_decel"]) << 2) |
        (int(speed_config["consider_intersection_right_out"]) << 3) |
        (int(speed_config["brake_hard_before_red_light"]) << 4) |
        (int(speed_config["ignore_intersection_right_in"]) << 5) |
        (int(speed_config["ignore_speed_limit"]) << 6)
    )
    
    return spd_mode_bin


def has_irregular_ndarray(arr: np.ndarray, extreme_threshold: float = 1e3) -> bool:
    """
    检查ndarray中是否存在异常值（NaN/Inf/绝对值超阈值的极端值）
    仅返回布尔值：存在异常值返回True，否则返回False
    
    参数:
        arr: 待检查的numpy.ndarray
        extreme_threshold: 极端值判定阈值（默认1000，绝对值超过该值即判定为异常）
    
    返回:
        bool: True（存在异常值）/ False（无异常值）
    """
    # 空数组直接返回False
    if arr.size == 0:
        return False
    
    # 1. 检查是否有NaN
    has_nan = np.any(np.isnan(arr))
    if has_nan:
        return True
    
    # 2. 检查是否有Inf（包含+Inf/-Inf）
    has_inf = np.any(np.isinf(arr))
    if has_inf:
        return True
    
    # 3. 检查是否有绝对值超阈值的极端值
    has_extreme = np.any(np.abs(arr) > extreme_threshold)
    
    return has_extreme


# 要记录到TensorBoard的自定义奖励字段（和Monitor中的info_keywords一致）
REWARD_KEYS = [
    "ttc_inv_penalty", "mei_reward", "rttc_inv_reward", "hw_penalty", "safe_reward",
    "collision_penalty", "speed_reward", "effi_reward", "allowed_lane_reward",
    "mission_reward", "navi_reward", "keep_right_reward", "speed_limit_reward",
    "rule_reward", "acc_reward", "comf_reward", "lane_change_reward",
    "lc_block_penalty", "repeat_lc_penalty", "opt_reward", "reward"
]


def init_reward_dict() -> dict:
    reward_dict = {}
    for key in REWARD_KEYS:
        reward_dict[key] = 0.0
    return reward_dict


def print_reward(reward_dict: dict):
    # 整理所有奖励项（名称 + 数值），按维度分类
    reward_details = [
        # 安全维度
        ("Safe-1/TTC", reward_dict["ttc_inv_penalty"]),
        ("Safe-MEI", reward_dict["mei_reward"]),
        ("Safe-RTTC", reward_dict["rttc_inv_reward"]),
        ("Safe-1/HW", reward_dict["hw_penalty"]),
        ("Safe Reward", reward_dict["safe_reward"]),
        ("Safe-Collision", reward_dict["collision_penalty"]),
        # 效率维度
        ("Effi-Speed", reward_dict["speed_reward"]),
        ("Effi Reward", reward_dict["effi_reward"]),
        # 导航维度
        ("Navi-Lane", reward_dict["allowed_lane_reward"]),
        ("Navi-Mission", reward_dict["mission_reward"]),
        ("Navi Reward", reward_dict["navi_reward"]),
        # 规则维度
        ("Rule-Keepright", reward_dict["keep_right_reward"]),
        ("Rule-Overspeed", reward_dict["speed_limit_reward"]),
        ("Rule Reward", reward_dict["rule_reward"]),
        # 舒适维度
        ("Comf-Accel", reward_dict["acc_reward"]),
        ("Comf Reward", reward_dict["comf_reward"]),
        # 操作合规维度
        ("Opti-Lane Change", reward_dict["lane_change_reward"]),
        ("Opti-Blocked", reward_dict["lc_block_penalty"]),
        ("Opti-Repeat Move", reward_dict["repeat_lc_penalty"]),
        ("Opti Reward", reward_dict["opt_reward"]),
        # 总奖励
        ("Total Reward", reward_dict["reward"])
    ]

    # 2. 定义ANSI转义字符（用于终端中加粗文本，是最直观的醒目方式）
    BOLD_START = "\033[1m"
    BOLD_END = "\033[0m"

    # 定义表格格式（左对齐名称，右对齐数值，保留4位小数）
    table_header = f"| {'Reward Name':<20} | {'Reward Value':>25} |"
    table_sep = f"|{'-'*22}|{'-'*27}|"

    # 打印表格
    print("\n" + "="*15 + " Reward Details Table " + "="*15)
    print(table_sep)
    print(table_header)
    print(table_sep)

    for name, val in reward_details:
        # 3. 判断是否为需要醒目的行：维度总结项 或 总奖励项
        is_dimension_summary = name.endswith(" Reward")  # 各维度总结（如Safe Reward）
        is_total_reward = name == "Total Reward"        # 总奖励
        
        if is_dimension_summary or is_total_reward:
            # 醒目行处理：加粗 + 专属标识
            if is_total_reward:
                # 总奖励额外加★符号，视觉优先级最高
                name_display = f"{BOLD_START}{name}{BOLD_END} "
                val_display = f"{BOLD_START}{val:>25.4f}{BOLD_END}"
            else:
                # 维度总结项加[维度总结]标识
                name_display = f"{BOLD_START}{name}---------{BOLD_END}"
                val_display = f"{BOLD_START}{val:>25.4f}{BOLD_END}"
            row = f"| {name_display:<28} | {val_display} |"  # 适配标识后的长度
        else:
            # 普通子项：保持原有格式
            row = f"| {name:<20} | {val:>15.4f}           |"
        
        print(row)

    print(table_sep)
    print("="*52 + "\n")



def create_gif(case_name:str, render_path:str, save_dir:str, remove_image:bool=False, frame_rate:int=25)->None:
    """_summary_
        # 创建GIF动画
        要求case_name不包含"."或者"_",比如"case1-seed-2"
        示例:
        render_path = "compass_env/output/"
        save_dir = "assets/gif/"
        case_name = "case1-seed-2"
    Args:
        case_name (str): 案例名称,不包含"."或者"_",比如"case1-seed-2"
        render_path (str): 渲染图像文件夹路径
        save_dir (str): 保存GIF文件夹路径
        remove_image (bool, optional): 是否删除渲染图像文件夹中的图像文件. Defaults to False.
        frame_rate (int, optional): GIF动画的帧率. Defaults to 25.
    """
    # 读取文件夹中的图像文件
    files = sorted(os.listdir(render_path), key=lambda x: int(x.split("_")[1].split(".")[0]))
    images = []
    imgs_to_delete = []
    for filename in files:
        img_dir = os.path.join(render_path, filename)
        img = imageio.imread(os.path.join(render_path, filename))
        images.append(img)
        imgs_to_delete.append(img_dir)

    images.append(img)

    imageio.mimsave(os.path.join(save_dir, case_name + ".gif"), [np.array(img) for i, img in enumerate(images)], fps=frame_rate)

    if remove_image:
        # 删除文件夹中的图像文件
        for img_dir in imgs_to_delete:
            os.remove(img_dir)