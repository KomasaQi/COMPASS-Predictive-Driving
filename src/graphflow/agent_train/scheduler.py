from typing import Callable
import math


def linear_schedule(initial_value: float) -> Callable[[float], float]:
    """
    Linear learning rate schedule.

    :param initial_value: Initial learning rate.
    :return: schedule that computes
      current learning rate depending on remaining progress
    """
    def func(progress_remaining: float) -> float:
        """
        Progress will decrease from 1 (beginning) to 0.

        :param progress_remaining:
        :return: current learning rate
        """
        return progress_remaining * initial_value

    return func




def cosine_annealing_schedule(initial_value: float, min_value: float = None) -> Callable[[float], float]:
    """
    Cosine annealing learning rate schedule with minimum learning rate.
    
    :param initial_value: Initial learning rate
    :param min_value: Minimum learning rate (default: 1% of initial value)
    :return: schedule that computes current learning rate depending on remaining progress
    """
    # 设置默认最小学习率为初始值的1%
    min_lr = min_value if min_value is not None else initial_value * 0.01
    
    def func(progress_remaining: float) -> float:
        """
        Progress will decrease from 1 (beginning) to 0 (end of training).
        
        :param progress_remaining: Remaining training progress (1.0 to 0.0)
        :return: current learning rate
        """
        # 余弦退火核心公式：lr = min_lr + 0.5*(initial_lr - min_lr)*(1 + cos(pi * (1 - progress_remaining)))
        # 当progress_remaining=1（训练开始）：lr = initial_lr
        # 当progress_remaining=0（训练结束）：lr = min_lr
        cos_term = math.cos(math.pi * (1 - progress_remaining))
        current_lr = min_lr + 0.5 * (initial_value - min_lr) * (1 + cos_term)
        
        # 确保学习率不会低于最小值（防止浮点误差）
        return max(current_lr, min_lr)
    
    return func