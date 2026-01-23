import torch
import torch.nn as nn

from common_layers import build_mlp  # 通用MLP构建函数（封装了线性层+激活+归一化）
from embedding import NATSequenceEncoder  # 导入embedding.py里的序列编码器（带FPN+邻域注意力）


class AgentEncoder(nn.Module):
    """
    智能体编码器：对自车(ego)和其他智能体的历史轨迹/状态/类型进行编码，输出高维特征
    核心逻辑：
    1. 把智能体的原始历史数据转换成「差分特征」（捕捉运动趋势）
    2. 用NATSequenceEncoder编码历史序列（融合多尺度时空特征）
    3. 单独编码自车的当前状态（替换历史编码结果，更精准）
    4. 融合智能体类型嵌入（区分车/人/自行车等）
    """
    def __init__(
        self,
        state_channel=53,       # 自车当前状态的维度（比如速度/朝向等，排除前2维后共51维）
        history_channel=24,     # 智能体历史序列的特征维度（最终拼接后是24维）
        dim=128,                # 最终输出的特征维度（和之前Query的D=128对齐）
        hist_steps=20,          # 历史时间步数量（比如过去20秒，1Hz采样→20步，这里取20）
        use_ego_history=False,  # 是否用自车的历史轨迹编码？False=用自车当前状态单独编码（更准）
        drop_path=0.2,          # NATSequenceEncoder中的drop path率（正则化，防止过拟合）
        state_attn_encoder=True,# 自车状态编码是否用注意力？True=用StateAttentionEncoder，False=用MLP
        state_dropout=0.75,     # StateAttentionEncoder中的dropout率（正则化）
        presence_index=0,       # 存在状态的索引（第0维），用于mask掉不存在的智能体
        v_type_index=-1,        # 车辆类型索引（最后一维），用于区分不同车辆类型
        **kwargs,               # 其他超参数
    ) -> None:
        super().__init__()
        self.dim = dim
        self.state_channel = state_channel
        self.use_ego_history = use_ego_history
        self.hist_steps = hist_steps
        self.state_attn_encoder = state_attn_encoder
        self.presence_index = presence_index
        self.v_type_index = v_type_index

        # 初始化「历史序列编码器」：用NATSequenceEncoder（来自embedding.py，带FPN+邻域注意力）
        # 输入通道=history_channel（24维），嵌入维度=dim//4=32，输出最终是dim=128维
        self.history_encoder = NATSequenceEncoder(
            in_chans=history_channel, embed_dim=dim // 4, drop_path_rate=drop_path
        )

        # 自车状态编码器：不用历史→单独编码当前状态
        if not use_ego_history:
            # 两种方案：不用注意力→MLP；用注意力→StateAttentionEncoder
            if not self.state_attn_encoder:
                self.ego_state_emb = build_mlp(state_channel, [dim] * 2, norm="bn")  # 两层MLP，输出dim=128
            else:
                self.ego_state_emb = StateAttentionEncoder(
                    state_channel, dim, state_dropout
                )

        # 智能体类型嵌入：14种类型（0=ego，1=car_eco, 2=car_sedan, 3=car_sport, 4=car_suv, 5=car_van, 
        # 6=bus, 7=truck_light, 8=truck_medium, 9=truck_heavy, 10=truck_concrete, 
        # 11=trailer_standard, 12=trailer_long, 13=trailer_double），每种对应一个dim=128的可学习向量
        self.type_emb = nn.Embedding(14, dim)


    def forward(self, obs):
        """
        前向传播：把原始智能体数据编码成高维特征
        参数data：字典，包含智能体的位置、朝向、速度、形状、类型、有效性掩码、自车当前状态等
        返回：
            x_agent + x_type: [B, V, dim] → 每个智能体的最终特征（融合了历史+类型）
        """
        T = self.hist_steps  # 历史时间步=21
        
        x_veh = obs["veh"]   # [B, V, T, Fv]
        # ========== 步骤1：提取原始数据 ==========
        v_type_idx = self.v_type_index if self.v_type_index != -1 else x_veh.shape[-1] - 1
        indexes = [i for i in range(x_veh.shape[-1]) if i not in [self.presence_index, v_type_idx]] # 排除presence和vtype后的索引
        veh_valid_features = x_veh[:, :, :, indexes]         # [B, V, T, Fv-2]
        vtype = x_veh[:, :, -1, self.v_type_index].long()     # [B, V] → 车辆类型
        valid_mask = x_veh[:, :, :, self.presence_index]     # [B, V, T] → 有效性掩码True:有效

        # ========== 步骤2：构建智能体的历史特征（差分+原始） ==========
        # 拼接所有特征→最终Fv-1维（对应history_channel）
        agent_feature = torch.cat(
            [
                veh_valid_features,                # [B, V, T, Fv-2]
                valid_mask.float().unsqueeze(-1),  # 有效性掩码（浮点型） [B,V,T,1]
            ],
            dim=-1,  # 拼接后：[B, V, T, Fv-2+1]
        )

        # ========== 步骤3：维度变换，适配NATSequenceEncoder ==========
        B, V, T, _ = agent_feature.shape
        # 合并batch和智能体维度：[B*V, T, Fv] → 因为NATSequenceEncoder处理单序列（每个智能体的历史是一个序列）
        agent_feature = agent_feature.view(B * V, T, -1)
        # 筛选有效智能体：只要有一个时间步有效，就是有效智能体 → [B*V]（True/False）
        valid_agent_mask = valid_mask.any(-1).flatten()

        # ========== 步骤4：用NATSequenceEncoder编码历史序列 ==========
        # NATSequenceEncoder输入要求：[B, C, L] → 所以permute(0,2,1)把[B*V, T,Fv-1]→[B*V,Fv-1,T]
        x_agent_tmp = self.history_encoder(
            agent_feature[valid_agent_mask].permute(0, 2, 1).contiguous()
        )  # 输出：[有效智能体数, dim=128]（NATSequenceEncoder最终输出最后一个时间步的特征）
        # 初始化全0特征，把有效智能体的编码结果填进去
        x_agent = torch.zeros(B * V, self.dim, device=x_veh.device)
        x_agent[valid_agent_mask] = x_agent_tmp


        # ========== 步骤5：单独编码自车(ego)状态（替换历史编码结果） ==========
        # use_ego_history=False → 不用自车的历史轨迹，用当前状态更精准
        if not self.use_ego_history:
            ego_feature = obs["ego"]   # [B, Fe]  → 自车当前状态（排除前两维度：绝对位置）
            x_ego = self.ego_state_emb(ego_feature)  # 编码成[B, 128]
            ego_type_emb = self.type_emb(torch.zeros(B, dtype=torch.long, device=x_veh.device)) # [B, 128] → 自车类型嵌入
            x_ego += ego_type_emb                    # [B, 128] 自车类型嵌入逐元素加和

        # ========== 步骤6：融合智能体类型嵌入 ==========
        x_type = self.type_emb(vtype.reshape(B*V))     # [B*V, 128] → 每个智能体的类型嵌入
        x_agent[valid_agent_mask] += x_type[valid_agent_mask]  # [B*V, 128] → 逐元素特征融合
        
        # 还原维度：[B*V, 128] → [B, V, 128]
        x_agent = x_agent.view(B, V, self.dim)
        return x_ego, x_agent, valid_agent_mask.reshape(B,V)  # 自车作为第0个智能体加入 [B, 128][B, V, 128][B, V]


class StateAttentionEncoder(nn.Module):
    """
    自车状态的注意力编码器：把自车的6维当前状态（比如速度、朝向、加速度）编码成128维特征
    核心：用注意力机制，让模型自动关注重要的状态维度（比如速度比位置更重要）
    """
    def __init__(self, state_channel, dim, state_dropout=0.0) -> None:
        super().__init__()

        self.state_channel = state_channel  # 自车状态维度=53
        self.state_dropout = state_dropout  # 训练时的token dropout率（正则化）
        # 为每个状态维度单独建一个线性层：把1维→dim维（比如第0维x坐标→128维）
        self.linears = nn.ModuleList([nn.Linear(1, dim) for _ in range(state_channel)])
        # 多头注意力层：4个头，每个头的维度=dim/4=32，输出dim=128
        self.attn = nn.MultiheadAttention(embed_dim=dim, num_heads=4, batch_first=True)
        # 位置嵌入：给每个状态维度加一个可学习的位置编码（区分不同维度）
        self.pos_embed = nn.Parameter(torch.Tensor(1, state_channel, dim))
        # 注意力查询向量：固定的1维查询，提取全局状态特征
        self.query = nn.Parameter(torch.Tensor(1, 1, dim))

        # 初始化参数（正态分布）
        nn.init.normal_(self.pos_embed, std=0.02)
        nn.init.normal_(self.query, std=0.02)

    def forward(self, x):
        """
        输入x：[B, state_channel=53] → 自车当前状态
        输出：[B, dim=128] → 编码后的自车特征
        """
        # ========== 步骤1：每个状态维度单独编码 ==========
        x_embed = []
        for i, linear in enumerate(self.linears):
            # x[:, i, None] → [B, 1]（取第i个维度，扩展成2维）
            x_embed.append(linear(x[:, i, None]))  # 每个维度→[B, 128]
        x_embed = torch.stack(x_embed, dim=1)  # 堆叠→[B, 6, 128]

        # ========== 步骤2：加位置嵌入 ==========
        pos_embed = self.pos_embed.repeat(x_embed.shape[0], 1, 1)  # [B,6,128]
        x_embed += pos_embed  # 残差式融合位置信息

        # ========== 步骤3：训练时的Token Dropout（正则化） ==========
        # 保留前3个维度（核心状态，比如位置/速度），随机dropout后面的维度（防止过拟合）
        if self.training and self.state_dropout > 0:
            visible_tokens = torch.zeros(
                (x_embed.shape[0], 51), device=x.device, dtype=torch.bool
            )  # 前51维不dropout（False=不屏蔽）
            dropout_tokens = (
                torch.rand((x_embed.shape[0], self.state_channel - 51), device=x.device)
                < self.state_dropout
            )  # 后0维随机dropout（True=屏蔽）
            key_padding_mask = torch.concat([visible_tokens, dropout_tokens], dim=1)  # [B,51]
        else:
            key_padding_mask = None  # 测试时不dropout

        # ========== 步骤4：注意力查询 ==========
        query = self.query.repeat(x_embed.shape[0], 1, 1)  # [B,1,128] → 每个batch用相同的查询

        # 自注意力：用固定查询提取全局状态特征
        x_state = self.attn(
            query=query,          # [B,1,128]
            key=x_embed,          # [B,51,128]
            value=x_embed,        # [B,51,128]
            key_padding_mask=key_padding_mask,  # 屏蔽dropout的维度
        )[0]  # 输出：[B,1,128]

        return x_state[:, 0]  # 取第0个token→[B,128]