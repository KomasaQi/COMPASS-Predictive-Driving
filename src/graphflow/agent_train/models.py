import functools

import gymnasium as gym
import numpy as np
import pygame
import seaborn as sns
import torch
import torch as th
import torch.nn as nn
from stable_baselines3 import PPO
from stable_baselines3.common.env_util import make_vec_env
from stable_baselines3.common.torch_layers import BaseFeaturesExtractor
from stable_baselines3.common.vec_env import SubprocVecEnv
from torch.distributions import Categorical
from torch.nn import functional as F
import tensorboard
import highway_env  # noqa: F401
from highway_env.utils import lmap
from agent_encoder import AgentEncoder
from fourier_embedding import FourierEmbedding

# ==================================
#        Policy Architecture
# ==================================

def activation_factory(activation_type):
    if activation_type == "RELU":
        return F.relu
    elif activation_type == "TANH":
        return torch.tanh
    elif activation_type == "ELU":
        return F.elu
    elif activation_type == "LEAKY_RELU":
        return F.leaky_relu
    elif activation_type == "SOFTPLUS":
        return F.softplus
    elif activation_type == "SOFTMAX":
        return F.softmax
    elif activation_type == "SIGMOID":
        return F.sigmoid
    elif activation_type == "GELU":
        return F.gelu
    else:
        raise ValueError(f"Unknown activation_type: {activation_type}")


class BaseModule(torch.nn.Module):
    """
    Base torch.nn.Module implementing basic features:
        - initialization factory
        - normalization parameters
    """

    def __init__(self, activation_type="RELU", reset_type="XAVIER"):
        super().__init__()
        self.activation = activation_factory(activation_type)
        self.reset_type = reset_type

    def _init_weights(self, m):
        if hasattr(m, "weight"):
            if self.reset_type == "XAVIER":
                torch.nn.init.xavier_uniform_(m.weight.data)
            elif self.reset_type == "ZEROS":
                torch.nn.init.constant_(m.weight.data, 0.0)
            else:
                raise ValueError("Unknown reset type")
        if hasattr(m, "bias") and m.bias is not None:
            torch.nn.init.constant_(m.bias.data, 0.0)

    def reset(self):
        self.apply(self._init_weights)


class MultiLayerPerceptron(BaseModule):
    def __init__(
        self,
        in_size=None,
        layer_sizes=None,
        reshape=True,
        out_size=None,
        activation="RELU",
        is_policy=False,
        **kwargs,
    ):
        super().__init__(**kwargs)
        self.reshape = reshape
        self.layer_sizes = layer_sizes or [64, 64]
        self.out_size = out_size
        self.activation = activation_factory(activation)
        self.is_policy = is_policy
        self.softmax = nn.Softmax(dim=-1)
        sizes = [in_size] + self.layer_sizes
        layers_list = [nn.Linear(sizes[i], sizes[i + 1]) for i in range(len(sizes) - 1)]
        self.layers = nn.ModuleList(layers_list)
        if out_size:
            self.predict = nn.Linear(sizes[-1], out_size)

    def forward(self, x):
        if self.reshape:
            x = x.reshape(x.shape[0], -1)  # We expect a batch of vectors
        for layer in self.layers:
            x = self.activation(layer(x.float()))
        if self.out_size:
            x = self.predict(x)
        if self.is_policy:
            action_probs = self.softmax(x)
            dist = Categorical(action_probs)
            return dist
        return x

    def action_scores(self, x):
        if self.is_policy:
            if self.reshape:
                x = x.reshape(x.shape[0], -1)  # We expect a batch of vectors
            for layer in self.layers:
                x = self.activation(layer(x.float()))
            if self.out_size:
                action_scores = self.predict(x)
            return action_scores




# ==================================
#        自车注意力模块(核心)
# ==================================
class EgoAttention(BaseModule):
    """
    基于自注意力的模块,核心逻辑：
    以自车(Ego)为查询(Query),所有车辆(自车+其他)为键(Key)和值(Value),计算注意力
    """
    def __init__(self, feature_dim=128, heads=4, dropout_factor=0.0):
        super().__init__()
        self.feature_size = feature_dim  # 每个实体的特征维度
        self.heads = heads               # 注意力头数(多头注意力)
        self.dropout_factor = dropout_factor # dropout概率
        # 每个注意力头的特征维度(必须能被heads整除)
        self.features_per_head = int(self.feature_size / self.heads)

        # 线性层：将特征映射到Q/K/V空间
        self.value_all = nn.Linear(self.feature_size, self.feature_size, bias=True)
        self.key_all = nn.Linear(self.feature_size, self.feature_size, bias=True)
        self.query_ego = nn.Linear(self.feature_size, self.feature_size, bias=True)
        
        # 注意力输出融合层
        self.attention_combine = nn.Linear(
            self.feature_size, self.feature_size, bias=True
        )

    @classmethod
    def default_config(cls):
        """默认配置(预留接口)"""
        return {}

    def forward(self, ego:torch.tensor, others:torch.tensor, mask:torch.tensor=None):
        """
        前向传播
        :param ego: 自车特征,维度 [B, F](B=批次, F=feature_size)
        :param others: 其他车辆特征,维度 [B, V-1, F](V=总车辆数)
        :param mask: 掩码(标记无效车辆),维度 [B, V](True表示车辆不存在)
        :return: 
            result: 自车融合注意力后的特征,维度 [B, F]
            attention_matrix: 注意力矩阵,维度 [B, H, 1, V](H=heads)
        """
        
        batch_size = others.shape[0]
        n_entities = others.shape[1] + 1
        input_all = torch.cat(
            (ego.view(batch_size, 1, self.feature_size), others), dim=1
        )
        # Dimensions: Batch, entity, head, feature_per_head
        key_all = self.key_all(input_all).view(
            batch_size, n_entities, self.heads, self.features_per_head
        )
        value_all = self.value_all(input_all).view(
            batch_size, n_entities, self.heads, self.features_per_head
        )
        query_ego = self.query_ego(ego).view(
            batch_size, 1, self.heads, self.features_per_head
        )

        # Dimensions: Batch, head, entity, feature_per_head
        key_all = key_all.permute(0, 2, 1, 3)
        value_all = value_all.permute(0, 2, 1, 3)
        query_ego = query_ego.permute(0, 2, 1, 3)
        if mask is not None:
            mask = mask.view((batch_size, 1, 1, n_entities)).repeat(
                (1, self.heads, 1, 1)
            )
        value, attention_matrix = attention(
            query_ego, key_all, value_all, mask, nn.Dropout(self.dropout_factor)
        )
        result = (
            self.attention_combine(value.reshape((batch_size, self.feature_size)))
            + ego.squeeze(1)
        ) / 2
        return result, attention_matrix


# ==================================
#        自车Transformer网络(整体封装)
# ==================================
class EgoTransformerNetwork(BaseModule):
    """
    完整的自车Transformer网络：
    1. 对所有车辆特征进行嵌入:ego注意力+NAT&FPN周车历史融合 + 傅里叶位置编码
    2. 用TransformerEncoder编码自车+周车特征，TransformerDecoder解码自车特征
    3. 输出融合后的自车特征
    """
    
    def __init__(
        self,
        embedding_layer_kwargs=None,
        attention_layer_kwargs=None,  # 保留参数以兼容原有调用，实际不再使用
        **kwargs,
    ):
        super().__init__(**kwargs)
        embedding_layer_kwargs = embedding_layer_kwargs or {}
        self.agent_encoder = AgentEncoder(**embedding_layer_kwargs)
        self.dim = self.agent_encoder.dim  # 特征维度，统一Transformer的d_model
        
        # ========== 1. 修改TransformerEncoder（batch_first=True） ==========
        self.trans_encoder = nn.TransformerEncoder(
            encoder_layer=nn.TransformerEncoderLayer(
                d_model=self.dim,          # 和嵌入维度一致
                nhead=attention_layer_kwargs.get('heads', 4),   # 需能被dim整除（如dim=128则nhead=4/8/16）
                dim_feedforward=self.dim,  # FFN维度，可根据需求调整
                dropout=0.1,
                activation='relu',
                batch_first=True,          # 关键：输入格式[B, V, F]
                norm_first=True,           # 推荐：归一化在前，更稳定
            ),
            num_layers=attention_layer_kwargs.get('num_layers', 2),
            norm=nn.LayerNorm(self.dim),   # 编码器最终归一化
        )
        
        # ========== 2. 修改TransformerDecoder（batch_first=True） ==========
        self.trans_decoder = nn.TransformerDecoder(
            decoder_layer=nn.TransformerDecoderLayer(
                d_model=self.dim,
                nhead=attention_layer_kwargs.get('heads', 4),   # 需能被dim整除（如dim=128则nhead=4/8/16）
                dim_feedforward=self.dim,
                dropout=0.1,
                activation='relu',
                batch_first=True,          # 关键：输入格式[B, V, F]
                norm_first=True,
            ),
            num_layers=attention_layer_kwargs.get('num_layers', 2),
            norm=nn.LayerNorm(self.dim),   # 解码器最终归一化
        )

        # ========== 移除原有的EgoAttention ==========
        # self.attention_layer = EgoAttention(**attention_layer_kwargs)

    def forward(self, x):
        # Step 1: 嵌入层输出（保持原有逻辑）
        ego, others, mask = self.agent_encoder(x)  # ego[B,F], others[B,V,F], mask[B,V]（True=周车有效）
        batch_size = ego.shape[0]
        num_others = others.shape[1] if others.dim() == 3 else 0

        # Step 2: 拼接自车+周车特征 → [B, 1+V, F]
        # ego扩展为[B,1,F]，和others[B,V,F]拼接
        ego_expand = ego.unsqueeze(1)  # [B,1,F]
        all_veh_feats = torch.cat([ego_expand, others], dim=1)  # [B, 1+V, F]

        # Step 3: 处理Transformer的padding mask（True=无效，需要屏蔽）
        # 自车mask：全有效 → False；周车mask：有效→False，无效→True（取反）
        ego_mask = torch.zeros((batch_size, 1), device=mask.device, dtype=torch.bool)  # [B,1] 自车必有效
        others_mask = ~mask  # 周车有效mask取反 → True=无效 [B,V]
        src_key_padding_mask = torch.cat([ego_mask, others_mask], dim=1)  # [B,1+V] 最终mask

        # Step 4: TransformerEncoder编码所有车辆特征
        encoder_out = self.trans_encoder(
            src=all_veh_feats,                # [B,1+V,F] 输入特征
            src_key_padding_mask=src_key_padding_mask  # [B,1+V] 无效车辆屏蔽
        )  # encoder_out: [B,1+V,F]

        # Step 5: TransformerDecoder解码（以自车原始特征为Query）
        # Decoder的Query：自车原始嵌入 [B,1,F]
        # Decoder的Key/Value：编码器输出 [B,1+V,F]
        decoder_out = self.trans_decoder(
            tgt=ego_expand,                   # Query: [B,1,F] 自车特征
            memory=encoder_out,               # Key/Value: [B,1+V,F] 编码器输出
            memory_key_padding_mask=src_key_padding_mask  # 屏蔽无效车辆
        )  # decoder_out: [B,1,F], attn_weights: 多层注意力权重（tuple）

        # Step 6: 处理输出 → 自车特征[B,F] + 注意力矩阵
        ego_embedded_att = decoder_out.squeeze(1)  # 去掉seq_len维度 → [B,F]

        # Step 7: 返回和原格式一致的结果
        return ego_embedded_att

# ==================================
#        自车注意力网络(整体封装)
# ==================================
class EgoAttentionNetwork(BaseModule):
    """
    完整的自车注意力网络：
    1. 对所有车辆特征进行嵌入:ego注意力+NAT&FPN周车历史融合
    2. 调用EgoAttention计算注意力
    3. 输出融合后的自车特征
    """
    
    def __init__(
        self,
        embedding_layer_kwargs=None,
        attention_layer_kwargs=None,
        **kwargs,
    ):
        super().__init__(**kwargs)
        embedding_layer_kwargs = embedding_layer_kwargs or {}
        self.agent_encoder = AgentEncoder(**embedding_layer_kwargs)

        attention_layer_kwargs = attention_layer_kwargs or {}
        self.attention_layer = EgoAttention(**attention_layer_kwargs)

    def forward(self, x):
        ego, others, mask = self.agent_encoder(x) 
        batch_size = ego.shape[0]
        mask = torch.cat([torch.ones((batch_size,1),device=mask.device),mask],dim=1) < 0.5 # 加入自车并对mask翻转:True表示无效
        ego_embedded_att, attention_matrix = self.attention_layer(ego, others, mask) 
        return ego_embedded_att, attention_matrix



# ==================================
#        缩放点积注意力(核心计算)
# ==================================
def attention(query, key, value, mask=None, dropout=None):
    """
    标准的缩放点积注意力(Scaled Dot-Product Attention)
    公式：Attention(Q,K,V) = softmax(QK^T/√d_k)V
    
    :param query: 查询张量,维度 [B, H, 1, d_k](1=自车单实体,d_k=F/H)
    :param key: 键张量,维度 [B, H, V, d_k]
    :param value: 值张量,维度 [B, H, V, d_k]
    :param mask: 掩码张量,维度 [B, H, 1, V](True位置会被设为-1e9,softmax后权重≈0)
    :param dropout: dropout层(可选)
    :return:
        output: 注意力输出 [B, H, 1, d_k]
        p_attn: 注意力权重 [B, H, 1, V]
    """
    d_k = query.size(-1)  # 每个注意力头的特征维度
    # 计算Q·K^T / √d_k：[B,H,1,d_k] @ [B,H,d_k,V] → [B,H,1,V]
    scores = torch.matmul(query, key.transpose(-2, -1)) / np.sqrt(d_k)
    
    # 掩码处理：True:无效位置设为极小值,softmax后权重接近
    if mask is not None:
        scores = scores.masked_fill(mask, -1e9)
    
    # 计算注意力权重(softmax归一化)
    p_attn = F.softmax(scores, dim=-1)  # [B,H,1,V]
    
    # Dropout(可选)
    if dropout is not None:
        p_attn = dropout(p_attn)
    
    # 注意力加权求和：[B,H,1,V] @ [B,H,V,d_k] → [B,H,1,d_k]
    output = torch.matmul(p_attn, value)
    return output, p_attn

class EgoTransformerExtractor(BaseFeaturesExtractor):
    """
    :param observation_space: (gym.Space)
    :param features_dim: (int) Number of features extracted.
        This corresponds to the number of unit for the last layer.
    """

    def __init__(self, observation_space: gym.spaces.Dict, **kwargs):
        super().__init__(
            observation_space,
            features_dim=kwargs["attention_layer_kwargs"]["feature_dim"],
        )
        self.extractor = EgoTransformerNetwork(**kwargs)

    def forward(self, observations: th.Tensor) -> th.Tensor:
        return self.extractor(observations)



class EgoAttentionExtractor(BaseFeaturesExtractor):
    """
    :param observation_space: (gym.Space)
    :param features_dim: (int) Number of features extracted.
        This corresponds to the number of unit for the last layer.
    """

    def __init__(self, observation_space: gym.spaces.Dict, **kwargs):
        super().__init__(
            observation_space,
            features_dim=kwargs["attention_layer_kwargs"]["feature_dim"],
        )
        self.extractor = EgoAttentionNetwork(**kwargs)

    def forward(self, observations: th.Tensor) -> th.Tensor:
        ego_embedded_att, _ = self.extractor(observations)
        return ego_embedded_att

    def get_attention_matrix(self, observations: th.Tensor) -> th.Tensor:
        _, attention_matrix = self.extractor(observations)
        return attention_matrix


class CustomCombinedExtractor(BaseFeaturesExtractor):
    """
    :param observation_space: (gym.Space)
    :param features_dim: (int) Number of features extracted.
        This corresponds to the number of unit for the last layer.
    """
    
    def __init__(self, observation_space: gym.spaces.Dict, **kwargs):
        # We do not know features-dim here before going over all the items,
        # so put something dummy for now. PyTorch requires calling
        # nn.Module.__init__ before adding modules
        super().__init__(observation_space, features_dim=1)

        extractors = {}

        total_concat_size = 0
        # We need to know size of the output of this extractor,
        # so go over all the spaces and compute output feature sizes
        for key, subspace in observation_space.spaces.items():
            print(key, subspace.shape, subspace)
            if key == "ego":
                # We will just downsample one channel of the image by 4x4 and flatten.
                # Assume the image is single-channel (subspace.shape[0] == 0)
                extractors[key] = nn.Sequential(nn.Flatten())
                total_concat_size += subspace.shape[0]
            elif key == "veh":
                # Run through a simple MLP
                extractors[key] = nn.Conv2d(subspace.shape[2], 128, kernel_size=(1,1), padding=1)
                total_concat_size += 128 * subspace.shape[0] * subspace.shape[1]

        self.extractors = nn.ModuleDict(extractors)

        # Update the features dim manually
        self._features_dim = total_concat_size

    def forward(self, observations) -> th.Tensor:
        encoded_tensor_list = []

        # self.extractors contain nn.Modules that do all the processing.
        for key, extractor in self.extractors.items():
            if key == "veh":
                x = observations[key]
                x = extractor(x.permute(0, 3, 1, 2)).permute(0, 2, 3, 1)
                encoded_tensor_list.append(x.flatten(start_dim=1))
            else:
                encoded_tensor_list.append(extractor(observations[key]))
        # Return a (B, self._features_dim) PyTorch tensor, where B is batch dimension.
        return th.cat(encoded_tensor_list, dim=1)






