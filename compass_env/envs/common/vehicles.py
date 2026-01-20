from __future__ import annotations

import numpy as np
from typing import Tuple

class VehicleDummy:
    def __init__(self, veh_id: str = None, pos: np.ndarray = None,
                 acc: float = None, speed: float = None, heading: float = None,
                 lane_id: str = None, lane_position: float = None, 
                 route: Tuple[str, ...] = None, heading_cos_sin: np.ndarray = None,
                 edge_id: str = None, route_index: int = None, dev: float = None,
                 length: float = 3.5, width: float = 1.8, v_class: str = 'unknown',
                 v_type: str = 'unknown', state: np.ndarray = None, history: np.ndarray = None) -> None:
        self.veh_id = veh_id
        self.pos = pos
        self.acc = acc
        self.speed = speed
        self.heading = heading
        self.lane_id = lane_id
        self.lane_position = lane_position
        self.route = route
        self.heading_cos_sin = heading_cos_sin
        self.edge_id = edge_id
        self.route_index = route_index
        self.dev = dev
        self.length = length
        self.width = width
        self.v_class = v_class
        self.v_type = v_type
        self.state = state
        self.history = history
        
    
    
    