from __future__ import annotations

import traci
from traci import constants as tc
import os, copy
import sys
import numpy as np
import random
import gymnasium as gym
from gymnasium import spaces
from typing import Optional, Dict, Any, Tuple, List, Union, TypeVar
import pandas as pd 
import math
import traceback
from compass_env import utils
from compass_env.utils import NeighborHistoryObs

class CompassFastParallelEnv(gym.Env): 
    """_summary_
    # Compass Highway Environment -- a Parallel Version and Fast Version with limited seeds
    
    A `highway driving environment` including `heterogeneous vehicles`.
    The controlled agent is a **semi-trailer tank truck**, and the other vehicles
    that interact with ego include various private cars, various trucks, and
    various buses as well as various semi-trailers.
    
    `Basic Missions` in this environment include 4
    - `passing` : passing through the ramps from the main road.
    - `merge` : merging into the main road from the ramps.
    - `exit` : exiting the main road to the ramps.
    - `cruise` : cruising on the main road.
    
    By resetting the environment, the ego vehicle will be assigned a random navigation
    task selected from the 4 basic missions with assignable seed to ensure reproducibility
    and to create random traffic flow in the finite scenarios.
    
    The basic gemetric road-net data is token from city `LianYungang` to city `YanCheng`.
    """
    
    metadata = {
        "render_modes": ["human", "console"],
        "valid_cases": [i for i in range(1, 28+1)],
    }
    N_ACTIONS = 2 # (1) ACCEL [-1, 1] (2) LANE_CHANGE [-1, 1]
    EGO_FEATURE_DIM = 53
    VEH_FEATURE_DIM = 25
    
    
    def __init__(self, config: dict = None, render_mode: str | None = None, verbose: bool = False) -> None:
        super().__init__()
 
        
        # Configuration
        self.config = self.default_config()
        if config is not None:
            self._deep_update(self.config, config)
        
        # SUMO Configuration
        if 'SUMO_HOME' in os.environ:
            tools = os.path.join(os.environ['SUMO_HOME'], 'tools')
            sys.path.append(tools)
        else:
            sys.exit("please declare environment variable 'SUMO_HOME'")
        
        # TraCI connection  
        self.conn = None
        self.traci_label = self.config["simulation"].get("traci_label", None)
        self.traci_port = int(self.config["simulation"].get("traci_port", 8813))
        
          
        if render_mode == "human":
            render_cmd = 'sumo-gui'
        else:
            render_cmd = 'sumo'
        self.render_cmd = render_cmd
        
        self.verbose = verbose
        
        
        # Case
        self.current_case = None
        self.all_case_info =  pd.read_excel(
            os.path.join(self.config["files"]["test_case_root"], 
                         self.config["files"]["test_case_info"]), sheet_name=0)
        self.case_info = None
        self.last_dist_to_goal = np.inf
        
        # Running
        self.time = 0  # Simulation time: actual time = time + time_bias, yet we only care about time
        self.time_bias = 0 # the time bias to start the simulation
        self.steps = 0  # Actions performed
        self.done = False
        
        # Rendering
        self._record_video_wrapper = None
        assert render_mode is None or render_mode in self.metadata["render_modes"]
        self.render_mode = render_mode
        self.enable_auto_render = False
        
        # Vehicle State and Object Tracking
        self.ego_state = None
        self.ego_vars = None
        self.veh_state = None
        self.veh_vars = None
        self.ego_route = None
        self.last_lc_time = -1e3
        self.nh_obs = None
        self.selected_vehs = None
        
        
        # Rewards
        self.cached_rewards = {}
        self.completed_mission = False # whether the mission is completed
        self.traci_cmd_working = False
        self.collision_state = False
        
        # Level files and Reloading
        self.level_files = utils.get_state_files(self.config["level_file_path"])
        self.already_start_sumo = False
        self.stored_obs = None
        self.stored_reward = None
        
        
        # Vehicle State Variables to Subscribe
        self.veh_state_vars = [
            tc.VAR_POSITION,            # (x, y) (m)
            tc.VAR_SPEED,               # v (m/s)
            tc.VAR_SPEED_LAT,           # v_lat (m/s)
            tc.VAR_ACCEL,               # a (m/s^2)
            tc.VAR_ANGLE,               # heading angle (deg) upright:0 deg clockwise: positive, 0 ~ 360
            tc.VAR_SIGNALS,             # turn signals / brake lights bitset  # bit0: right bit1: left bit2: emergent bit3: brake ...
            
            tc.VAR_ALLOWED_SPEED,       # speed limit (m/s)
            tc.VAR_ROAD_ID,             # edge id (str)
            tc.VAR_LANE_ID,             # lane id (str)
            tc.VAR_LANE_INDEX,          # lane index (int)
            tc.VAR_LANEPOSITION,        # position along lane (m)
            tc.VAR_LANEPOSITION_LAT,    # position along lane (lat relative to current lane center) (m)
            tc.VAR_ROUTE_INDEX,         # route index (int)
            
            tc.VAR_LENGTH,              # vehicle length
            tc.VAR_WIDTH,               # vehicle width (if available)
            tc.VAR_TYPE,                # vType
            tc.VAR_VEHICLECLASS,        # vClass
            tc.VAR_MAXSPEED,            # max speed (m/s)
            tc.VAR_ACCELERATION,        # allowed acc (m/s^2)
        ]

        # Define action and observation space
        self.action_space = spaces.Box(low=-1, high=1, shape=(self.N_ACTIONS,), dtype=np.float32) # TODO: realize action type factory: discrete
        self.observation_space = spaces.Dict({
            "ego": spaces.Box(low=-np.inf, high=np.inf,
                                            shape=(self.EGO_FEATURE_DIM, ), dtype=np.float32),
            "veh": spaces.Box(low=-np.inf, high=np.inf,
                                            shape=(self.config["observation"]["vehicles_count"],
                                                   self.config["observation"]["history_length"],
                                                   self.VEH_FEATURE_DIM, ), dtype=np.float32),
        })
        # self.reset()

    def default_config(self) -> dict:
        config = {
            "egoID": "t_0",
            "observation":{
                "history_length": 20,  # the number of history steps to be included in the observation 
                "vehicles_count": 15,  # the max number of vehicles observed  
                "tracking_dict_len": 50, # the max number of vehicles tracked in the observation area
                "relative_pos": True,  # whether to use relative position instead of absolute position 
                "obsolate_time": 10.0, # the time duration to obsolate a vehicle in the observation area
                "extend_lane_num": 3,
                "obs_radius": 500.0,   # the radius of the observation area
                "ttc_inv_lim": 2.0,    # the maximum 1 / time-to-collision with the front vehicle
            },
            "action":{
                "type": "continuous", # the type of action space, "continuous" or "discrete"
                "settings":{
                    "max_accel": 1.5, # the maximum acceleration of the ego vehicle
                    "max_decel": 2.5, # the maximum deceleration of the ego vehicle
                    "lc_time": 4, # the time duration of attempting lane change (not execution time)
                    "lc_thred": 0.33, # the threshold th of lane change action [-1:-th):R, [-th:th]:K, (th:1]:L
                },
            },
            "reward":{ 
                "acc_reward": -0.1, # the reward of accelerating and decelerating
                "lane_change_reward": -0.1, # the reward when changing lane
                "speed_reward": 0.5, # the reward when speeding up
                "min_reward_speed_ratio": 0.6, # the minimum speed ratio to the allowed speed to calculate the reward
                "allowed_lane_reward": 0.02, # the reward when staying in the allowed lane 
                "mission_reward": 5.0, # the reward when completing the navigation task 
                "keep_right_reward": 0.05, # the reward when keeping right when in cruise mission
                "speed_limit_reward": -0.5, # the reward when exceeding the speed limit
                "ttc_inv_reward": -0.5, # the reward of time-to-collision with the front vehicle 
                "mei_reward": -0.3, # the reward of modified Emergency Index with all other vehicles 
                "ttc_2d_inv_reward": -0.3, # the reward of 2D time-to-collision with all other vehicle 
                "hw_inv_reward": -0.02, # the reward of heading away of the front vehicle as well as left right front neihgbors 
                "lc_block_penalty": -1.0, # the penalty when lane change is blocked
                "repeat_move_penalty": -0.05, # the penalty when change lane when last TraCI command still works
                "collision_penalty": -5.0, # the penalty when colliding with other vehicles
            },
            "simulation":{
                "time_step": 1.0, # the time step of the simulation in seconds
                "durration": 500, # the simulation time duration in second
                "min_velocity_to_terminate": 1.0, # m/s the minimum velocity to early terminate the simulation
                "goal_tolerance": 35.0, # m the tolerance distance to the goal
                "traci_port": 8813,          # Default port (will be overridden by parallel)
                "traci_label": None,         # Default None, generated or passed externally on reset  
            },
            "gui":{
                "view": "View #0",
                "schema": "real world",
                "zoom": 80000,
                "screen_width": 640,  # [px]
                "screen_height": 640,  # [px]
            },
            "case_num": -1, # the index of the current test case -1 means randomly choose a test case
            "files":{
                "test_case_root": os.path.join("data", "test_cases"),
                "test_case_info": "COMPASS_TestCase_LianYG_YanC.xlsx", # TODO: use this param
            },
            "level_file_path": os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "levels"),

        } # TODO: implement other parameters
        
        return config

    def step(self, action):
        """
        Apply the action to the ego vehicle and step the simulation.
        """ 
        # Apply action
        self._apply_action(action)
        
        # Step the simulation
        self.steps += 1
        self.time += self.config["simulation"]["time_step"]
        # Step the simulation
        try:
            self.conn.simulationStep(self.time + self.time_bias)

        except Exception as e:
            info = {"fatal_sumo": True, "fatal_msg": str(e)}
            print(info["fatal_msg"])
            self.already_start_sumo = False
            return self.stored_obs, self.stored_reward, True, False, info
        
        # Update vehicle state
        self._update_vehicle_state()
 
                
        observation = self._get_observation() 
        reward = self._reward(observation)
        terminated = self._is_terminated()
        truncated = self._is_truncated() 
        if terminated or truncated:
            self.done = True
        # Optionally we can pass additional info, we are not using that for now
        info = {}
        self.stored_obs = observation
        self.stored_reward = reward
        return observation, reward, terminated, truncated, info

    def _start_sumo(self, seed: int):
        # 0) 关闭旧连接
        try:
            if self.conn is not None:
                self.conn.close()
        except Exception:
            pass
        self.conn = None

        # 1) label 唯一化
        if self.traci_label is None:
            self.traci_label = f"compass-{os.getpid()}-{id(self)}"

        # 2) sumocfg 绝对路径 + 切工作目录到 sumocfg 所在目录
        sumocfg_abs = os.path.abspath(os.path.join(
            self.config["files"]["test_case_root"], self.case_info["sumocfg_file"]
        ))
        cfg_dir = os.path.dirname(sumocfg_abs)
        cfg_name = os.path.basename(sumocfg_abs)

        old_cwd = os.getcwd()
        os.chdir(cfg_dir)

        # 3) 给每个 env 单独日志（非常重要：否则你只看到 TraCI 警告，看不到 SUMO 为什么退出）
        log_tag = self.traci_label.replace(":", "_")
        sumo_log = os.path.join(cfg_dir, f"sumo_{log_tag}.log")
        sumo_err = os.path.join(cfg_dir, f"sumo_{log_tag}.err")

        # 4) 让 traci.start 管理 remote-port：cmd 里不要自己写 --remote-port
        cmd = [
            self.render_cmd, "-c", cfg_name,
            "--start", "--quit-on-end",
            "--seed", str(seed),
            "--log", sumo_log,
            "--error-log", sumo_err,
            "--no-step-log",  # 可选：减少输出干扰
            "--collision.action", "teleport",
        ]

        port = int(self.traci_port)

        try:
            # 关键：port 参数要传给 traci.start，cmd 里不要带 --remote-port
            traci.start(cmd, port=port, label=self.traci_label)
            self.conn = traci.getConnection(self.traci_label)
        finally:
            os.chdir(old_cwd)




    def reset(self, seed=None, options=None):
        super().reset(seed=seed, options=options)
        # 重置环境变量
        self.steps = 0
        self.time = 0.0
        self.last_dist_to_goal = np.inf
        self.done = False
        self.ego_vars = None
        self.ego_state = None
        self.veh_state = None
        self.veh_vars = None
        self.ego_route = None
        self.last_lc_time = -1e3
        self.selected_vehs = None
        self.cached_rewards = {}
        self.completed_mission = False
        self.traci_cmd_working = False
        self.collision_state = False
        
        # 重置测试用例
        if self.config["case_num"] == -1:
            self.current_case = np.random.choice(self.metadata["valid_cases"])
        else:
            self.current_case = self.config["case_num"]
        self._get_case_info()
        if seed is None:
            seed = np.random.randint(0, 10000)
        
        # 首先进行一次探测保证SUMO启动成功
        if self.conn is not None:
            try:
                self.conn.getVersion()
            except Exception as e:
                print(f"Failed to connect to SUMO: {e}")
                self.already_start_sumo = False
            
        try:
            if not self.already_start_sumo:
                # 启动SUMO仿真
                self._start_sumo(seed)
            else:
                # 选取当前测试用例对应的level文件
                case_level_files = [f for f in self.level_files if f"level_{self.current_case}_" in str(f)]
                self.conn.simulation.loadState(str(random.choice(case_level_files)))
            
            ego_id = self.config["egoID"]
            
            # 设置可视化界面
            if self.render_mode == 'human':
                ViewID = self.config["gui"]["view"]
                self.conn.simulation.getTime()
                self.conn.gui.setSchema(ViewID, self.config["gui"]["schema"])
                self.conn.gui.setZoom(ViewID, self.config["gui"]["zoom"])
                self.conn.gui.trackVehicle(ViewID, ego_id)

            # 仿真到指定开始时间，确保自车出现
            if not self.already_start_sumo:
                self.time_bias = self.case_info["init_time"]
                self.conn.simulationStep(self.time_bias)
                revised_counter = 0
                while self.conn.vehicle.getRouteIndex(ego_id) < 0: # 确保自车出现（可能由于随机性，导致自车出现被阻塞）
                    self.time_bias += 1
                    revised_counter += 1
                    self.conn.simulationStep(self.time_bias)
                    if revised_counter > 1000:
                        print("Ego vehicle doesn't show up in {} steps, automatically reset the environment".format(revised_counter))
                        # self.reset(seed=seed, options=options) # 递归调用reset，重新启动环境
            else:
                self.time_bias = self.conn.simulation.getTime() + 1.0
                try:
                    self.conn.getVersion()
                except Exception as e:
                    print(f"Failed to connect to SUMO after loading state: {e}")
                    self.already_start_sumo = False
                    observation, info = self.reset(seed=seed, options=options)
                
                self.conn.simulationStep(self.time_bias)
            
            
            # 订阅自车和周车相关变量
            self.conn.vehicle.subscribe(ego_id, self.veh_state_vars)
            self.conn.vehicle.subscribeContext(
                ego_id,
                tc.CMD_GET_VEHICLE_VARIABLE,
                self.config["observation"]["obs_radius"],
                varIDs=self.veh_state_vars,
            )
            self.ego_route = self.conn.vehicle.getRoute(ego_id)
            
            self.nh_obs = NeighborHistoryObs(
                obs_radius=self.config["observation"]["obs_radius"],
                history_length=self.config["observation"]["history_length"],
                vehicle_counts=self.config["observation"]["vehicles_count"],
                tracking_dict_len=self.config["observation"]["tracking_dict_len"],
                relative_pos= self.config["observation"]["relative_pos"],
                ttl = self.config["observation"]["obsolate_time"],
                ttc_inv_lim = self.config["observation"]["ttc_inv_lim"],
                ego_id=self.config["egoID"],
            )
            
            
            # Update vehicle state
            self._update_vehicle_state()
            
            
            observation = self._get_observation()
            # Optionally we can pass additional info, we are not using that for now
            info = {}
            if not self.already_start_sumo:
                self.already_start_sumo = True
        except Exception as e:
            print("Error in reset: ", e)
            # traceback.print_exc()
            self.already_start_sumo = False
            observation, info = self.reset(seed=seed, options=options)
        
        
        return observation, info

    def _apply_action(self, action):
        """
        # 应用动作到环境中
        :param action: 动作数组，[lane_change, acceleration]
        """
        egoID = self.config["egoID"]
        settings = self.config['action']['settings']
        if self.config['action']['type'] == 'continuous':
            action_lc = action[0]
            action_acc = action[1]
            
            # 处理车道变化指令
            lane_idx = self.ego_vars[tc.VAR_LANE_INDEX]
            lane_num = self.conn.edge.getLaneNumber(self.ego_vars[tc.VAR_ROAD_ID])
            repeat_lc_cmd = False
            if action_lc < -settings['lc_thred']:
                lc_cmd = -1
                self.last_lc_time = self.time
                if self.traci_cmd_working:
                    repeat_lc_cmd = True
            elif action_lc > settings['lc_thred']:
                lc_cmd = 1
                self.last_lc_time = self.time
                if self.traci_cmd_working:
                    repeat_lc_cmd = True
            else:
                lc_cmd = None
            target = lane_idx + lc_cmd if lc_cmd is not None else lane_idx
            
            # 处理加速度指令
            dt = self.config['simulation']['time_step']
            if action_acc > 0:
                acc_cmd = action_acc * settings['max_accel']
            else:
                acc_cmd = action_acc * settings['max_decel']
                
            speed_des_cmd = self.ego_vars[tc.VAR_SPEED] + acc_cmd * dt
            
            self.conn.vehicle.setSpeed(egoID, speed_des_cmd)
            if 0 <= target < lane_num:
                if lc_cmd is not None:
                    self.conn.vehicle.changeLaneRelative(egoID, lc_cmd, settings['lc_time']) # 1: 相对车道变化，0: 绝对车道变化
            # TODO:添加非法换道惩罚
                
            # 处理重复车道变化指令惩罚
            repeat_lc_penalty = self.config["reward"]["repeat_move_penalty"] if repeat_lc_cmd else 0.0
            self.cached_rewards.update({'repeat_lc_penalty': repeat_lc_penalty})

            
        elif self.config['action']['type'] == 'discrete':
            raise NotImplementedError("Discrete action type is not implemented yet.") # TODO: Add discrete action type
        else:
            raise ValueError("Invalid action type. Expected 'continuous' or 'discrete'.")
            


    def _update_vehicle_state(self):
        """
        # 更新自车和周车的状态
        """
        # 获取订阅变量
        veh_vars = self.conn.vehicle.getContextSubscriptionResults(self.config["egoID"])
        ego_vars = self.conn.vehicle.getSubscriptionResults(self.config["egoID"])  
        self.veh_vars = veh_vars # 存储周车状态
        self.ego_vars = ego_vars # 存储自车状态

        # 关键：lane_id 无效 -> 直接终止，不要 raise
        lane_id = ego_vars.get(tc.VAR_LANE_ID, "")
        edge_id = ego_vars.get(tc.VAR_ROAD_ID, "")
        if (not isinstance(lane_id, str)) or (lane_id == "") or (not isinstance(edge_id, str)) or (edge_id == ""):
            self.collision_state = True
            print("Ego Collision detected at time {} (expression: lane_id or edge_id is empty)".format(self.time))
            return

        # 筛选在观测范围内的周车
        ego_x, ego_y = ego_vars[tc.VAR_POSITION]
        neighbors = []
        # veh_vars: {vehID: {varID: value}}
        for vid, vars_ in veh_vars.items():
            x, y = vars_[tc.VAR_POSITION]
            # 只对半径内车辆计算距离，k 通常远小于 N
            dx = x - ego_x
            dy = y - ego_y
            dist = math.hypot(dx, dy)
            neighbors.append((vid, dist, vars_))

        neighbors.sort(key=lambda t: t[1])
        neighbors = neighbors[:self.config["observation"]["tracking_dict_len"]]
        
        # 更新自车状态
        self._calc_ego_state()
        collision_id_list = self.conn.simulation.getStartingTeleportIDList()
        if collision_id_list and self.config["egoID"] in collision_id_list:
            self.collision_state = True
            print(f"Ego collision detected at time {self.time}(expression: Teleport)")
        else:
            self.collision_state = False
        
        
    def _calc_ego_state(self):
        """
        * **自车状态**:
            - 绝对位置        0 1
            - 速度            2 3
            - 航向角绝对      4 5
            - 灯语状态        6 7 8
            - 位于匝道/主路    9
            - 车道索引        10
            - 车道偏移        11
            - 当前限速        12
            - 当前道路进度    13
            - 车辆长度        14
            - 车辆宽度        15
            - 车辆类型vClass  16
            - 车辆最高车速     17
            - 导航意图(one-hot)  18 19 20
            - **前/后/左前/左后/右前/右后1/TTC**  21 22 23 24 25 26
            - **上次换道间隔**   27 
            - 下一条车道限速    28
            - **可通行车道mask** 29 - 35 (3+1+3=7)
            - 换道状态(one-hot)  36 - 52 (17)
            特征维度:53
        """
        ego_vars = self.ego_vars
        ego_id = self.config["egoID"]
        heading = utils.convert_sumo_angle(ego_vars[tc.VAR_ANGLE])
        signal_state = utils.embed_signal_state(ego_vars[tc.VAR_SIGNALS])
        laneLength = self.conn.lane.getLength(ego_vars[tc.VAR_LANE_ID])
        lanePosition = ego_vars[tc.VAR_LANEPOSITION_LAT]
        remLaneDist = max(0, laneLength - lanePosition)
        mission = utils.descern_mission(self.case_info['mission'])
        remLaneDist = max(0, laneLength - lanePosition)
        route_index = ego_vars[tc.VAR_ROUTE_INDEX]
        if route_index == len(self.ego_route) - 1:
            next_lane_speedlim = ego_vars[tc.VAR_ALLOWED_SPEED]
        else:
            next_lane_speedlim = self.conn.lane.getMaxSpeed(self.ego_route[route_index + 1] + "_0")
            
        length, width = utils.normalize_bbox(ego_vars[tc.VAR_LENGTH], ego_vars[tc.VAR_WIDTH])
        extend_lane_num=self.config["observation"]["extend_lane_num"]
        can_reach_multi = self._can_reach_next_edge_multi(veh_id=ego_id,extend_lane_num=extend_lane_num,
                                                          current_lane=ego_vars[tc.VAR_LANE_ID],
                                                          current_edge=ego_vars[tc.VAR_ROAD_ID],
                                                          current_lane_index=ego_vars[tc.VAR_LANE_INDEX],
                                                          route_index=ego_vars[tc.VAR_ROUTE_INDEX])
        front_ttc, back_ttc, left_f_ttc, left_r_ttc, right_f_ttc, right_r_ttc = \
                                        self._calc_ttc(veh_id=ego_id, ego_speed=ego_vars[tc.VAR_SPEED], 
                                                       can_reach_multi=can_reach_multi, remLaneDist=remLaneDist)
        lc_state = self.lane_change_state_encoder(veh_id=ego_id)
        
        til = self.config["observation"]["ttc_inv_lim"]
        
        ego_state = np.array([
            0.0,0.0, # ego_vars[tc.VAR_POSITION][0], ego_vars[tc.VAR_POSITION][1],     # 0:x 1:y
            utils.normalize_speed(ego_vars[tc.VAR_SPEED]), ego_vars[tc.VAR_SPEED_LAT], # 2:vx (normalize) 3:vy
            np.cos(heading), np.sin(heading),                                          # 4:cos_h 5:sin_h
            signal_state[0], signal_state[1], signal_state[2],                         # 6:left 7:right 8:brake
            ego_vars[tc.VAR_ALLOWED_SPEED] > 15,                                       # 9:on_main_road 用最简单的方法判断是否在主路：道路限速
            ego_vars[tc.VAR_LANE_INDEX],                                               # 10: lane_index
            ego_vars[tc.VAR_LANEPOSITION_LAT],                                         # 11: lane_dev
            utils.normalize_speed(ego_vars[tc.VAR_ALLOWED_SPEED]),                     # 12: speed_lim (normalize)
            1 - remLaneDist/laneLength,                                                # 13: lane_progress
            length, width,                                                             # 14: length 15: width (normalize)
            utils.encode_vehicle_class(ego_vars[tc.VAR_VEHICLECLASS]),                 # 16: v_class
            utils.normalize_speed(ego_vars[tc.VAR_MAXSPEED]),                          # 17: max_speed (normalize)
            mission[0], mission[1], mission[2],                                        # 18: pass/cruise 19: merge 20: exit
            np.clip(self._safe_inv(front_ttc), -til, til),                             # 21: front_ttc
            np.clip(self._safe_inv(back_ttc), -til, til),                              # 22: back_ttc
            np.clip(self._safe_inv(left_f_ttc), -til, til),                            # 23: left_f_ttc
            np.clip(self._safe_inv(left_r_ttc), -til, til),                            # 24: left_r_ttc
            np.clip(self._safe_inv(right_f_ttc), -til, til),                           # 25: right_f_ttc
            np.clip(self._safe_inv(right_r_ttc), -til, til),                           # 26: right_r_ttc
            1.0 /(self.time - self.last_lc_time),                                      # 27: last_lc_time_inv
            utils.normalize_speed(next_lane_speedlim),                                 # 28: next_lane_speedlim (normalize)
            ])  
        ego_state = np.concatenate([ego_state, can_reach_multi.astype(float), lc_state])
        
        self.ego_state = ego_state
        
        # 计算奖励
        # ttc_reward = np.clip(1/front_ttc, -til, til)
        
        
        can_reach = can_reach_multi[extend_lane_num]
        allowed_lane_reward = self.config["reward"]["allowed_lane_reward"] if can_reach else 0.0
        self.cached_rewards.update({"allowed_lane_reward": allowed_lane_reward})
        
        if self.verbose:
            print('can_reach_multi   : ', ''.join(['○' if i else '●' for i in can_reach_multi]))
            print('speed / speedlim  : {:.2f} / {:.2f} km/h'.format(ego_vars[tc.VAR_SPEED]*3.6, ego_vars[tc.VAR_ALLOWED_SPEED]*3.6))
            print('laneID / edgeID   : ',ego_vars[tc.VAR_LANE_ID],',', ego_vars[tc.VAR_ROAD_ID])
            print('lanePos / remDist : {:.2f} / {:.2f} m'.format(lanePosition, remLaneDist))

        
        
    
    def _get_observation(self):
        """
        # 获取当前环境的观测
        :return: Dict, 包含自车和他车的观测
        """
        # ego_state 兜底
        if self.ego_state is None:
            ego_obs = np.zeros((self.EGO_FEATURE_DIM,), dtype=np.float32)
            print('Warning: ego_state is None')
        else:
            ego_obs = self.ego_state.astype(np.float32)
        
        # nh_obs 或 veh_vars 兜底
        if (self.nh_obs is None) or (self.ego_vars is None) or (self.veh_vars is None):
            veh_obs = np.zeros(
                (self.config["observation"]["vehicles_count"],
                self.config["observation"]["history_length"],
                self.VEH_FEATURE_DIM),
                dtype=np.float32
            )
            self.selected_vehs = []
        else:
            veh_obs, self.selected_vehs = self.nh_obs.step_build_obs(self.steps, self.ego_vars, self.veh_vars)
            veh_obs = veh_obs.astype(np.float32)
        
        return {"ego": ego_obs, "veh": veh_obs}

    def _reward(self, observation:Dict):
        """
        ## 计算当前步骤奖励
        * **奖励函数**: 
        - **`安全`**
            - 1/TTC惩罚:前车和后车的TTC都参与计算✅️
            - MEI惩罚:Modified Emergency Index惩罚✅️
            - 1/HW惩罚:Headway 惩罚✅️
            - 1/RTTC惩罚:2D Time-To-Collision惩罚✅️
            - 碰撞惩罚：发生碰撞时，给予惩罚✅️
        - **`效率`**
            - 高速行驶奖励：从限速最低阈值开始线性增加到限速✅️
        - **`导航`**
            - 可通行车道奖励：处于符合导航要求的可通行车道✅️
            - 完成导航任务奖励：完成导航任务后奖励✅️
        - **`规则`**
            - 保持右侧车道奖励：在需要保持右侧车道的情况下，保持右侧车道奖励✅️
            - 超速惩罚: 依据交通法规, 超出110%限速范围，进行惩罚✅️
        - **`舒适/节能`**
            - 加速度惩罚：根据加速度平方计算惩罚✅️
        - **`操作合规`**
            - 频繁/重复指令：正在换道时，再次下发指令扣分✅️
            - 换道阻塞惩罚：换道指令下发后，出现阻塞状态扣分✅️
        # TODO: Add actual reward
        return reward
        """
        # 基本状态获取
        ego_speed = self.ego_vars[tc.VAR_SPEED]
        if self.collision_state:
            lane_num = None
        else:
            lane_num = self.conn.edge.getLaneNumber(self.ego_vars[tc.VAR_ROAD_ID])
        need_to_keep_right = False
        last_mission_state = self.completed_mission
        mission = self.case_info["mission"]
        if 'pass' in mission:
            if self.last_dist_to_goal < 45.0 and not self.completed_mission:
                self.completed_mission = True
        elif 'cruise' in mission:
            need_to_keep_right = True
            if self.last_dist_to_goal < 45.0 and not self.completed_mission:
                self.completed_mission = True
        elif 'merge' in mission:
            need_to_keep_right = True
            if self.ego_vars[tc.VAR_ALLOWED_SPEED] > 15.0 and not self.completed_mission: # 行驶到主路
                self.completed_mission = True
        elif 'exit' in mission:
            need_to_keep_right = True
            if self.ego_vars[tc.VAR_ALLOWED_SPEED] < 15.0 and not self.completed_mission: # 行驶到匝道
                self.completed_mission = True
        
        # 安全奖励：TTC、MEI、THW、HW
        # (1) 1/TTC惩罚:前车和后车的TTC都参与计算 
        try:
            ttc_inv_penalty = self.cached_rewards["ttc_inv_reward"]
        except Exception as e:
            print("ttc_inv_penalty error:{}".format(e))
            ttc_inv_penalty = 0.0
        
        # (2) MEI惩罚: 和所有车的MEI
        try:
            mei_index = self.nh_obs.veh_feat_var.get("mei", None)
            on_main_road_index = self.nh_obs.veh_feat_var.get("on_main_road", None)

            mei_reward = 0.0
            if mei_index is not None:
                meis = observation["veh"][:, -1, mei_index]
                if on_main_road_index is not None:
                    ego_on_main_road = bool(self.ego_vars[tc.VAR_ALLOWED_SPEED] > 15)
                    mask = (observation["veh"][:, -1, on_main_road_index] == ego_on_main_road)
                    cand = meis[mask]
                else:
                    cand = meis

                if cand.size > 0:
                    mei = float(np.max(cand))
                    mei_reward = self.config["reward"]["mei_reward"] * max(mei, 0.0)
        except Exception as e:
            print("mei_reward error:{}".format(e))
            mei_reward = 0.0
            
        # (3) 1/RTTC惩罚:和所有车的RTTC
        try:
            rttc_inv_reward = 0.0
            rttc_inv_index = self.nh_obs.veh_feat_var.get("rttc_1", None)
            if rttc_inv_index is not None:
                rttc = observation["veh"][:, -1, rttc_inv_index]
                if rttc.size > 0:
                    rttc_1 = float(np.max(rttc))
                    rttc_inv_reward = self.config["reward"]["ttc_2d_inv_reward"] * max(rttc_1, 0.0)
        except Exception as e:
            print("rttc_inv_reward error:{}".format(e))
            rttc_inv_reward = 0.0
        
        # (4) 1/HW惩罚：和周边所有车的HW最小值
        try:
            hw_penalty = self.cached_rewards["hw_inv_reward"]
        except Exception as e:
            print("hw_penalty error:{}".format(e))
            hw_penalty = 0.0
        # (5) 碰撞惩罚：发生碰撞时，给予惩罚
        try:
            collision_penalty = self.config["reward"]["collision_penalty"] if self.collision_state else 0.0
        except Exception as e:
            print("collision_penalty error:{}".format(e))
            collision_penalty = 0.0
        
        safe_reward = ttc_inv_penalty + mei_reward + rttc_inv_reward + hw_penalty + collision_penalty
        
        
        # 效率奖励：
        # (1) 高速行驶奖励: 从限速最低阈值开始线性增加到限速
        try:
            max_rew_spd_ratio = self.ego_vars[tc.VAR_ALLOWED_SPEED]
            min_rew_spd_ratio = max_rew_spd_ratio * self.config["reward"]["min_reward_speed_ratio"]
            speed_reward = self.config["reward"]["speed_reward"] * (ego_speed - min_rew_spd_ratio) / (max_rew_spd_ratio - min_rew_spd_ratio)
        except Exception as e:
            print("speed_reward error:{}".format(e))
            speed_reward = 0.0
        
        effi_reward = speed_reward
        
        # 导航奖励：
        # (1) 可通行车道奖励
        try:
            allowed_lane_reward = self.cached_rewards["allowed_lane_reward"]
        except Exception as e:
            print("allowed_lane_reward error:{}".format(e))
            allowed_lane_reward = 0.0
        
        # (2) 完成导航任务奖励
        try:
            mission_reward = self.config["reward"]["mission_reward"] * (self.completed_mission - last_mission_state)
        except Exception as e:
            print("mission_reward error:{}".format(e))
            mission_reward = 0.0
        
        navi_reward = allowed_lane_reward + mission_reward
        
        # 规则奖励：
        # (1) 保持右侧车道奖励
        try:
            if need_to_keep_right and lane_num is not None and lane_num > 1:
                keep_right_reward = self.config["reward"]["keep_right_reward"] * (lane_num - 1 - self.ego_vars[tc.VAR_LANE_INDEX]) / (lane_num - 1)
            else:
                keep_right_reward = 0.0
        except Exception as e:
            print("keep_right_reward error:{}".format(e))
            keep_right_reward = 0.0
        
        # (2) 限速奖励
        try:
            speed_limit_reward = self.config["reward"]["speed_limit_reward"] * max(ego_speed - 1.1*max_rew_spd_ratio, 0.0) / max_rew_spd_ratio
        except Exception as e:
            print("speed_limit_reward error:{}".format(e))
            speed_limit_reward = 0.0
            
            
        rule_reward = keep_right_reward + speed_limit_reward
        
        # 舒适/节能奖励：
        # (1) 加速度惩罚
        try:
            acc_reward =  self.ego_vars[tc.VAR_ACCEL]**2 * self.config["reward"]["acc_reward"]
        except Exception as e:
            print("acc_reward error:{}".format(e))
            acc_reward = 0.0
        
        comf_reward = acc_reward
        
        # 操作合规奖励：
        # (1) 换道代价惩罚
        try:
            lane_change_reward = self.config["reward"]["lane_change_reward"] if (self.time - self.last_lc_time) <= self.config["simulation"]["time_step"] else 0.0
        except Exception as e:
            print("lane_change_reward error:{}".format(e))
            lane_change_reward = 0.0
        # (2) 换道阻塞惩罚
        try:
            lc_block_penalty = self.cached_rewards["lc_block_penalty"]
        except Exception as e:
            print("lc_block_penalty error:{}".format(e))
            lc_block_penalty = 0.0
        
        # (3) 重复换道惩罚
        try:
            repeat_lc_penalty = self.cached_rewards["repeat_lc_penalty"]
        except Exception as e:
            print("repeat_lc_penalty error:{}".format(e))
            repeat_lc_penalty = 0.0
        
        opt_reward = lane_change_reward + lc_block_penalty + repeat_lc_penalty
           
        
        reward = safe_reward + effi_reward + navi_reward + rule_reward + comf_reward + opt_reward
        
        # 以表格形式打印奖励
        if self.verbose:
            # 整理所有奖励项（名称 + 数值），按维度分类
            reward_details = [
                # 安全维度
                ("Safe-1/TTC", ttc_inv_penalty),
                ("Safe-MEI", mei_reward),
                ("Safe-RTTC", rttc_inv_reward),
                ("Safe-1/HW", hw_penalty),
                ("Safe Reward", safe_reward),
                ("Safe-Collision", collision_penalty),
                # 效率维度
                ("Effi-Speed", speed_reward),
                ("Effi Reward", effi_reward),
                # 导航维度
                ("Navi-Lane", allowed_lane_reward),
                ("Navi-Mission", mission_reward),
                ("Navi Reward", navi_reward),
                # 规则维度
                ("Rule-Keepright", keep_right_reward),
                ("Rule-Overspeed", speed_limit_reward),
                ("Rule Reward", rule_reward),
                # 舒适维度
                ("Comf-Accel", acc_reward),
                ("Comf Reward", comf_reward),
                # 操作合规维度
                ("Opti-Lane Change", lane_change_reward),
                ("Opti-Blocked", lc_block_penalty),
                ("Opti-Repeat Move", repeat_lc_penalty),
                ("Opti Reward", opt_reward),
                # 总奖励
                ("Total Reward", reward)
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
        
        return float(reward)

    def render(self):
        # TODO: Add actual render
        # self.conn.gui.screenshot(viewID=self.config["gui"]["view"], filename="compass_env/output/screenshot.png", width=640,height=480)
        pass

    def close(self):
        try:
            if self.conn is not None:
                self.conn.close()
        except Exception as e:
            print("Error in close: ", e)
            # traceback.print_exc()
        self.conn = None

    
    def _is_terminated(self) -> bool:
        """
        # 判断环境是否终止
        # 如果自车速度小于最小速度阈值  
        # 到达终点即停止
        :return: bool，True=终止，False=未终止
        """
        speed_terminated = self.ego_vars[tc.VAR_SPEED] < self.config["simulation"]["min_velocity_to_terminate"]
        dist_to_goal = np.linalg.norm(np.array(self.ego_vars[tc.VAR_POSITION]) - self.case_info["goal"])
        goal_tolerance = self.config["simulation"]["goal_tolerance"]
        goal_terminated = dist_to_goal <= goal_tolerance or (
            (dist_to_goal <= goal_tolerance*1.5) and (dist_to_goal > self.last_dist_to_goal)
        ) # 加入一个安全系数保证两个仿真步之间不会冲过去
        self.last_dist_to_goal = dist_to_goal
        if self.collision_state:
            print("Collision terminated at time {}".format(self.time))
        if self.verbose:
            print("dist_to_goal: ", dist_to_goal)
            if speed_terminated:
                print("Speed terminated at time {}".format(self.time))
            if goal_terminated:
                print("Goal terminated at time {}".format(self.time))

        return bool(speed_terminated or goal_terminated or self.collision_state)
    
    def _is_truncated(self) -> bool:
        """
        # 判断环境是否截断
        :return: bool，True=截断，False=未截断
        """
        truncated = self.time >= self.config["simulation"]["durration"]
        if truncated:
            print("Truncated at time {}".format(self.time))
        return bool(truncated)
    


  
    def can_reach_next_edge(self, veh_id):
        """
        # 判断该车当前车道能否到达下个目标edge
        :param veh_id: 主车ID
        :param next_target_edge: 目标下一个edge ID
        :return: bool，True=能到达，False=不能
        """
        # 步骤1：获取当前车道ID和下一个edgeID
        current_lane = self.conn.vehicle.getLaneID(veh_id)
        routeIndex = self.conn.vehicle.getRouteIndex(veh_id)
        route = self.conn.vehicle.getRoute(veh_id)
        if routeIndex == len(route) - 1:
            return True # 没有下一个边了，默认返回可达
        next_target_edge = route[routeIndex + 1]
        # 步骤2：获取该车道可驶出的edge列表
        outgoing_edges = self.conn.lane.getLinks(current_lane)
        # 步骤3：判断目标edge是否在列表中
        for i in outgoing_edges:
            if self.conn.lane.getEdgeID(i[0]) == next_target_edge:
                return True
        return False

    
    def _can_reach_next_edge_multi(self, veh_id, extend_lane_num=1, current_lane=None, 
                                  current_edge=None, current_lane_index=None, route_index=None):
        """
        # 判断该车当前车道和左右的N条车道能否到达下个目标edge
        :param veh_id: 主车ID
        :param extend_lane_num: 左右扩展车道数，默认1条, 即共 1 + 2*extend_lane_num 条车道
        :return: bool array，True=能到达，False=不能
        """
        lanes_to_judge = 1 + 2*extend_lane_num
        can_reach = np.zeros(lanes_to_judge, dtype=bool)
        # 步骤1：获取当前车道ID和下一个edgeID
        if current_lane is None:
            current_lane = self.conn.vehicle.getLaneID(veh_id)
        if current_edge is None:
            current_edge = self.conn.lane.getEdgeID(current_lane)
        lane_number = self.conn.edge.getLaneNumber(current_edge)
        if current_lane_index is None:
            current_lane_index = self.conn.vehicle.getLaneIndex(veh_id)
        right_rem_num = min(current_lane_index, extend_lane_num)
        left_rem_num = min(lane_number - 1 - current_lane_index, extend_lane_num)
        rem_indexs = np.arange(current_lane_index - right_rem_num, current_lane_index + 1 + left_rem_num)
        if route_index is None:
            route_index = self.conn.vehicle.getRouteIndex(veh_id)
        
        if route_index == len(self.ego_route) - 1:
            can_reach[rem_indexs] = True
            return np.flip(can_reach) # 没有下一个边了，默认返回可达
        
        next_target_edge = self.ego_route[route_index + 1]
        # 步骤2：获取该车道可驶出的edge列表
        for i in rem_indexs:
            the_lane = current_edge + '_' + str(i)
            outgoing_edges = self.conn.lane.getLinks(the_lane)
            # 步骤3：判断目标edge是否在列表中
            for j in outgoing_edges:
                if self.conn.lane.getEdgeID(j[0]) == next_target_edge:
                    can_reach[i - current_lane_index + extend_lane_num] = True
                    break
        return np.flip(can_reach)

    
    def _calc_ttc(self, veh_id, clip=100.0, ego_speed=None, can_reach_multi=None, remLaneDist=None):
        """_summary_
        # 计算给定车辆前/后分别的TTC
        Args:
            veh_id (string): 计算TTC的车辆ID
            clip (float, optional): TTC的clip值，默认100.0秒.
            ego_speed (float, optional): 主车速度，默认None. 
            dummy_obs_dist (float, optional): 虚拟障碍物距离，用于当前车道不能到达下一个edge时的TTC计算，默认None.
        """
        front_ttc = clip
        back_ttc = clip
        eps = 1e-6
        if ego_speed is None:
            ego_speed = self.conn.vehicle.getSpeed(veh_id)

        # 初始化前车和后车ID为None
        leader_id = None
        follower_id = None
        
        # 获取前车和后车ID
        leader_dist = 1e3
        leader = self.conn.vehicle.getLeader(veh_id)
        if leader is not None:
            leader_id, leader_dist = leader
            
        follower_dist = 1e3
        follower = self.conn.vehicle.getFollower(veh_id)
        if follower is not None:
            follower_id, follower_dist = follower
            
        # 如果存在前车就计算TTC
        if isinstance(leader_id, str) and leader_id and self._valid_veh_id(leader_id):
            leader_speed = self.conn.vehicle.getSpeed(leader_id)
            front_ttc = leader_dist / (ego_speed - leader_speed + eps)
            
        if isinstance(follower_id, str) and follower_id and self._valid_veh_id(follower_id):
            follower_speed = self.conn.vehicle.getSpeed(follower_id)
            back_ttc = follower_dist / (follower_speed - ego_speed + eps)
            
        ego_lane_idx = self.config["observation"]["extend_lane_num"]
        if (remLaneDist is not None) and (can_reach_multi[ego_lane_idx]):
            front_ttc = min(front_ttc, remLaneDist / (ego_speed + eps))
            

        left_leaders = self.conn.vehicle.getLeftLeaders(veh_id)
        left_followers = self.conn.vehicle.getLeftFollowers(veh_id)
        right_leaders = self.conn.vehicle.getRightLeaders(veh_id)
        right_followers = self.conn.vehicle.getRightFollowers(veh_id)
        

        # 1. 计算最近的right leader的TTC（改写后）
        min_right_leader_dist = 1e3
        min_right_leader_id = None
        right_f_ttc = clip

        # 过滤无效项（None / "" / 非str）
        right_leader_cand = [(vid, dist) for (vid, dist) in right_leaders if isinstance(vid, str) and vid]
        if right_leader_cand:
            # 直接用min函数找最近的leader（替代原for循环）
            min_right_leader_id, min_right_leader_dist = min(right_leader_cand, key=lambda x: x[1])
            
            # 存在性检查：车辆可能在同一步被移除/teleport
            if self._valid_veh_id(min_right_leader_id):
                right_leader_speed = self.conn.vehicle.getSpeed(min_right_leader_id)
                right_f_ttc = min(right_f_ttc, min_right_leader_dist / (ego_speed - right_leader_speed + eps))

        # 2. 计算最近的left leader的TTC（改写后）
        min_left_leader_dist = 1e3
        min_left_leader_id = None
        left_f_ttc = clip

        # 过滤无效项（None / "" / 非str）
        left_leader_cand = [(vid, dist) for (vid, dist) in left_leaders if isinstance(vid, str) and vid]
        if left_leader_cand:
            # 直接用min函数找最近的leader（替代原for循环）
            min_left_leader_id, min_left_leader_dist = min(left_leader_cand, key=lambda x: x[1])
            
            # 存在性检查：车辆可能在同一步被移除/teleport
            if self._valid_veh_id(min_left_leader_id):
                left_leader_speed = self.conn.vehicle.getSpeed(min_left_leader_id)
                left_f_ttc = min(left_f_ttc, min_left_leader_dist / (ego_speed - left_leader_speed + eps))

        # 3. 计算right follower的TTC（改写后）
        min_right_follower_dist = 1e3
        min_right_follower_id = None
        right_r_ttc = clip

        # 过滤无效项（None / "" / 非str）
        right_follower_cand = [(vid, dist) for (vid, dist) in right_followers if isinstance(vid, str) and vid]
        if right_follower_cand:
            # 直接用min函数找最近的follower（替代原for循环）
            min_right_follower_id, min_right_follower_dist = min(right_follower_cand, key=lambda x: x[1])
            
            # 存在性检查：车辆可能在同一步被移除/teleport
            if self._valid_veh_id(min_right_follower_id):
                right_follower_speed = self.conn.vehicle.getSpeed(min_right_follower_id)
                right_r_ttc = min(right_r_ttc, min_right_follower_dist / (right_follower_speed - ego_speed + eps))

        # 4. 原left follower的TTC计算（保持不变）
        min_left_follower_dist = 1e3
        min_left_follower_id = None
        left_r_ttc = clip

        # 过滤无效项（None / "" / 非str）
        cand = [(vid, dist) for (vid, dist) in left_followers if isinstance(vid, str) and vid]
        if cand:
            min_left_follower_id, min_left_follower_dist = min(cand, key=lambda x: x[1])

            # 再做存在性检查：车辆可能在同一步被移除/teleport
            if self._valid_veh_id(min_left_follower_id):
                left_follower_speed = self.conn.vehicle.getSpeed(min_left_follower_id)
                left_r_ttc = min(left_r_ttc, min_left_follower_dist / (left_follower_speed - ego_speed + eps))

        
        if (remLaneDist is not None) and (can_reach_multi[ego_lane_idx - 1]):
            right_f_ttc = min(right_f_ttc, remLaneDist / (ego_speed + eps))
        
        if (remLaneDist is not None) and (can_reach_multi[ego_lane_idx + 1]):
            left_f_ttc = min(left_f_ttc, remLaneDist / (ego_speed + eps))
            
        front_ttc = np.sign(front_ttc) * min(abs(front_ttc), clip)
        back_ttc = np.sign(back_ttc) * min(abs(back_ttc), clip)
        left_f_ttc = np.sign(left_f_ttc) * min(abs(left_f_ttc), clip)
        left_r_ttc = np.sign(left_r_ttc) * min(abs(left_r_ttc), clip)
        right_f_ttc = np.sign(right_f_ttc) * min(abs(right_f_ttc), clip)
        right_r_ttc = np.sign(right_r_ttc) * min(abs(right_r_ttc), clip)
        
        if self.verbose:
            print('front / back TTC  : {:.2f} / {:.2f} s'.format(front_ttc, back_ttc))
            print('lf / lr TTC       : {:.2f} / {:.2f} s'.format(left_f_ttc, left_r_ttc))
            print('rf / rr TTC       : {:.2f} / {:.2f} s'.format(right_f_ttc, right_r_ttc))
            print('leader            : ',leader)
            print('follower          : ',follower)
            print('left leaders      : ',left_leaders)
            print('left followers    : ',left_followers)
            print('right leaders     : ',right_leaders)
            print('right followers   : ',right_followers)
        
        # 计算一些安全代价
        # (1) 1/TTC惩罚：和前车后车的TTC
        threat_front_inv_ttc = 1/max(front_ttc,0.2) if front_ttc > 0.0 else 0.0
        threat_back_inv_ttc = 1/max(back_ttc,0.2) if back_ttc > 0.0 else 0.0
        self.cached_rewards.update({
            "ttc_inv_reward": self.config["reward"]["ttc_inv_reward"] * (threat_front_inv_ttc + threat_back_inv_ttc), # the reward of time-to-collision with the front vehicle 
        })
        
        # (2) 1/HW惩罚：和周边所有车的HW最小值
        hw = max(0.2, min(leader_dist, follower_dist, min_left_leader_dist, min_right_leader_dist, min_left_follower_dist, min_right_follower_dist))
        self.cached_rewards.update({
            "hw_inv_reward": self.config["reward"]["hw_inv_reward"] * 1/hw, # the reward of heading away of the front vehicle as well as left right front neihgbors
        })
        
        
        return front_ttc, back_ttc, left_f_ttc, left_r_ttc, right_f_ttc, right_r_ttc
    
    
    def lane_change_state_encoder(self, veh_id):
        """_summary_
        # 手动编码车辆的换道状态
        Args:
            veh_id (string): 被编码车辆的ID

        Returns:
            lc_state (int array): 
                    bit 0:是否处于紧急状态     urgent
                    bit 1:是否被左前阻塞       blocked by left leader
                    bit 2: 是否被左后阻塞      blocked by left follower
                    bit 3: 是否被右前阻塞      blocked by right leader
                    bit 4: 是否被右后阻塞      blocked by right follower
                    bit 5: 是否重叠阻塞        overlapping
                    bit 6: 是否正在向左换道    left
                    bit 7: 是否正在向右换道    right
                    bit 8: 是否可以向左换道    could left
                    bit 9: 是否可以向右换道    could right
                    bit 10: 是否正在战略变道   strategic
                    bit 11: 是否在速度增益变道 speedGain
                    bit 12: 是否在合作变道     cooperative
                    bit 13: 是否子车道变换中   sublane
                    bit 14: 有无TraCI指令     TraCI
                    bit 15: 是否空间不足       insufficient space
                    bit 16: 是否保持右车道     keepRight
        """
        # 初始化换道状态数组
        lc_state = np.zeros(17)
        
        # 分别获得左右换道状态并合并
        lc_state_L = self.conn.vehicle.getLaneChangeStatePretty(veh_id, tc.LANECHANGE_LEFT)[1]  # 取考虑TraCI指令的状态[1]
        lc_state_R = self.conn.vehicle.getLaneChangeStatePretty(veh_id, tc.LANECHANGE_RIGHT)[1]
        state_fdbk = tuple(dict.fromkeys(list(lc_state_L) + list(lc_state_R)).keys()) # 合并并去重
        
        # 检查是否可以向左右换道
        could_lc_L = self.conn.vehicle.couldChangeLane(veh_id, tc.LANECHANGE_LEFT)
        could_lc_R = self.conn.vehicle.couldChangeLane(veh_id, tc.LANECHANGE_RIGHT)
        
        lc_state[0] = 1 if 'urgent' in state_fdbk else 0
        lc_state[1] = 1 if 'blocked by left leader' in state_fdbk else 0
        lc_state[2] = 1 if 'blocked by left follower' in state_fdbk else 0
        lc_state[3] = 1 if 'blocked by right leader' in state_fdbk else 0
        lc_state[4] = 1 if 'blocked by right follower' in state_fdbk else 0
        lc_state[5] = 1 if 'overlapping' in state_fdbk else 0
        lc_state[6] = 1 if 'left' in state_fdbk else 0
        lc_state[7] = 1 if 'right' in state_fdbk else 0
        lc_state[8] = 1 if could_lc_L else 0
        lc_state[9] = 1 if could_lc_R else 0
        lc_state[10] = 1 if 'strategic' in state_fdbk else 0
        lc_state[11] = 1 if 'speedGain' in state_fdbk else 0
        lc_state[12] = 1 if 'cooperative' in state_fdbk else 0
        lc_state[13] = 1 if 'sublane' in state_fdbk else 0
        lc_state[14] = 1 if 'TraCI' in state_fdbk else 0
        lc_state[15] = 1 if 'insufficient space' in state_fdbk else 0
        lc_state[16] = 1 if 'keepRight' in state_fdbk else 0
        
        if self.verbose:
            print('could LC left     : ',could_lc_L)
            print('could LC right    : ',could_lc_R)
            print('LC state L        : ',lc_state_L)
            print('LC state R        : ',lc_state_R)
            print('LC state          : ', ''.join(['○' if i else '●' for i in lc_state]))
        
        # 计算换道阻塞惩罚
        lc_block_penalty = 0.0
        if (sum(lc_state[0:6]) or lc_state[15]) and lc_state[14]: # 有换道阻塞或空间不足，且是由于TraCI指令导致的
            lc_block_penalty = self.config["reward"]["lc_block_penalty"]
        
        self.cached_rewards["lc_block_penalty"] = lc_block_penalty
        
        self.traci_cmd_working = True if 'TraCI' in state_fdbk else False
        
        
        return lc_state
        
        
    def _get_case_info(self):
        """_summary_
        获取当前案例的信息

        Returns:
            dict: 案例的信息
        """
        case_id = int(self.current_case)
        case_index = case_id - 1
        self.case_info = {
            "case_id": case_id,
            "sumocfg_file": "no" + str(case_id) + "_" + str(int(self.all_case_info.Avg_Stream[case_index])) 
                            + "_" + self.all_case_info.Name[case_index] + ".sumocfg",
            "route_file": "no" + str(case_id) + "_" + str(int(self.all_case_info.Avg_Stream[case_index])) 
                            + "_" + self.all_case_info.Name[case_index] + ".rou.xml",
            "goal": np.array([self.all_case_info.EndPosX[case_index], self.all_case_info.EndPosY[case_index]]),
            "init_time": float(self.all_case_info.InitTime[case_index]),
            "mission": self.all_case_info.Name[case_index],
        }

    def _deep_update(self, base: dict, new: dict):
        for k, v in new.items():
            if isinstance(v, dict) and isinstance(base.get(k), dict):
                self._deep_update(base[k], v)
            else:
                base[k] = v


    def _valid_veh_id(self, vid):
        return isinstance(vid, str) and len(vid) > 0 



    @staticmethod
    def _safe_inv(x: float, eps: float = 1e-6):
        # 保留符号的倒数，避免除零
        if x is None:
            return 0.0
        if abs(x) < eps:
            return 0.0
        return 1.0 / x