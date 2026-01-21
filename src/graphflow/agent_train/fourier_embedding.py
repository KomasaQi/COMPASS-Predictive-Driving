# Copyright (c) 2023, Zikang Zhou. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import math
from typing import List, Optional

import torch
import torch.nn as nn


class FourierEmbedding(nn.Module):
    """
    傅里叶嵌入（Fourier Embedding）模块
    核心功能：
        将低维连续数值特征（如时间步、坐标x/y、速度、朝向角等）通过**频率变换+非线性编码**映射到高维隐藏空间，
        利用三角函数（cos/sin）的周期性捕捉连续特征的周期模式（比如时间的昼夜周期、车辆运动的周期性），
        提升模型对连续数值的表征能力（比单纯线性层更能捕捉非线性/周期性规律）。
    
    输入输出维度示例（方便理解）：
        假设：input_dim=3（比如x/y/z坐标）、num_freq_bands=16、hidden_dim=128
        输入：continuous_inputs → [B, T, 3] （B=批次=16，T=时间步=20，3=输入维度）
        输出：高维嵌入向量 → [B, T, 128] （128=隐藏维度）
    """
    def __init__(
        self, 
        input_dim: int,        # 输入的连续特征维度（比如3=xyz坐标，1=时间步，2=速度vx/vy）
        hidden_dim: int,       # 输出的高维嵌入维度（比如128/256，和模型其他模块维度对齐）
        num_freq_bands: int    # 傅里叶频率带数量（控制周期模式的丰富度，越多捕捉的周期越细）
    ) -> None:
        super(FourierEmbedding, self).__init__()
        self.input_dim = input_dim    # 记录输入维度
        self.hidden_dim = hidden_dim  # 记录输出维度

        # 可学习的频率嵌入层：每个输入维度对应num_freq_bands个可学习频率
        # 作用：让模型自动学习不同输入维度的最优频率（比如时间维度适合低频，坐标维度适合高频）
        # 维度：self.freqs.weight → [input_dim, num_freq_bands]（示例：[3,16]）
        self.freqs = nn.Embedding(input_dim, num_freq_bands) if input_dim != 0 else None
        
        # 为每个输入维度单独配置一个MLP（非线性编码）
        # 原因：不同输入维度的周期模式不同（比如x坐标和时间的周期特征完全不同），单独编码更精准
        # 每个MLP结构：Linear(2*num_freq_bands+1 → hidden_dim) → LayerNorm → ReLU → Linear(hidden_dim→hidden_dim)
        # 输入维度=2*num_freq_bands+1：cos(num_freq_bands) + sin(num_freq_bands) + 原始特征(1)
        self.mlps = nn.ModuleList(
            [
                nn.Sequential(
                    nn.Linear(num_freq_bands * 2 + 1, hidden_dim),  # 频率特征→高维
                    nn.LayerNorm(hidden_dim),                       # 层归一化，稳定训练
                    nn.ReLU(inplace=True),                          # 非线性激活，捕捉复杂模式
                    nn.Linear(hidden_dim, hidden_dim),              # 进一步细化高维特征
                )
                for _ in range(input_dim)  # 每个输入维度对应一个MLP
            ]
        )
        
        # 最终融合层：对所有维度的嵌入求和后，做最终的归一化+激活+线性变换
        # 作用：融合所有输入维度的特征，输出最终的高维嵌入
        self.to_out = nn.Sequential(
            nn.LayerNorm(hidden_dim),
            nn.ReLU(inplace=True),
            nn.Linear(hidden_dim, hidden_dim),
        )

    def forward(
        self,
        continuous_inputs: Optional[torch.Tensor],  # 连续输入特征，维度[B, ..., input_dim]（示例[16,20,3]）
    ) -> torch.Tensor:
        """
        前向传播：傅里叶频率变换 → 三角函数编码 → 逐维度MLP → 融合 → 最终输出
        以下维度注释均以「示例：input_dim=3, num_freq_bands=16, continuous_inputs=[16,20,3]」为例
        """
        # ===================== 步骤1：傅里叶频率变换（生成多频率的弧度值） =====================
        # 1.1 扩展原始特征维度：[16,20,3] → [16,20,3,1]（为了和频率权重广播相乘）
        # 1.2 乘以可学习频率 + 2π：将特征值转换为「多频率的弧度值」（三角函数输入要求弧度）
        # self.freqs.weight维度[3,16]，广播后相乘结果：[16,20,3,1] × [3,16] → [16,20,3,16]
        # 作用：为每个输入维度生成num_freq_bands个不同频率的信号，捕捉不同尺度的周期模式
        x = continuous_inputs.unsqueeze(-1) * self.freqs.weight * 2 * math.pi

        # ===================== 步骤2：三角函数编码（捕捉周期性） =====================
        # 2.1 对弧度值分别做cos/sin变换：x.cos()/x.sin() → [16,20,3,16]
        # 作用：cos/sin是周期函数，能将连续数值的「绝对大小」转换为「相对周期位置」（比如359°和1°的cos值接近）
        # 2.2 拼接：cos + sin + 原始特征 → 保留周期特征+原始数值特征
        # 拼接后维度：[16,20,3, 16+16+1=33]（num_freq_bands×2 +1）
        x = torch.cat([x.cos(), x.sin(), continuous_inputs.unsqueeze(-1)], dim=-1)

        # ===================== 步骤3：逐维度MLP编码（非线性映射） =====================
        # 初始化列表，存储每个输入维度的编码结果
        continuous_embs: List[Optional[torch.Tensor]] = [None] * self.input_dim
        for i in range(self.input_dim):  # 遍历每个输入维度（0=x,1=y,2=z）
            # 取第i个维度的特征：[16,20,3,33] → [16,20,33]
            # 经过对应MLP编码：[16,20,33] → [16,20,128]
            continuous_embs[i] = self.mlps[i](x[..., i, :])

        # ===================== 步骤4：融合所有维度的特征 =====================
        # 堆叠所有维度的编码结果：[3,16,20,128] → 求和（dim=0）→ [16,20,128]
        # 作用：将x/y/z三个维度的高维特征融合为一个整体特征
        x = torch.stack(continuous_embs).sum(dim=0)

        # ===================== 步骤5：最终变换（归一化+激活+线性） =====================
        # 输出维度：[16,20,128]（和hidden_dim一致）
        # 作用：稳定特征分布，进一步捕捉非线性模式，输出最终的傅里叶嵌入
        return self.to_out(x)