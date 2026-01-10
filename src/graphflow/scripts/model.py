# -*- coding: utf-8 -*-
"""
@Author: Komasa Qi
@Contact: komasaqi@foxmail.com
"""
from typing import Optional
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch_geometric.nn import GATConv, GCNConv, GATv2Conv, TransformerConv, PerformerAttention, SGFormerAttention, ChebConv
from torch import Tensor
from torch_geometric.nn.attention import PolynormerAttention
from torch_geometric.utils import to_dense_batch
import math
from layers import EnhancedPolynormer, EnhancedSGFormer

class SinusoidalPosEmb(nn.Module):
    def __init__(self, dim):
        super().__init__()
        self.dim = dim

    def forward(self, t):
        # t: (B,) floats (works for continuous t too)
        device = t.device
        half = self.dim // 2
        emb = torch.exp(torch.arange(half, device=device) * -(math.log(10000) / (half - 1)))
        emb = t[:, None].float() * emb[None, :]
        emb = torch.cat([torch.sin(emb), torch.cos(emb)], dim=-1)
        if self.dim % 2 == 1:
            emb = F.pad(emb, (0, 1))
        return emb  # (B, dim)

class Graphflower(nn.Module):
    def __init__(self, args, num_node_features, num_edge_features):
        super().__init__()
        self.T = args.time_length
        self.Cd = args.dyn_feature_dim
        self.Cs = args.static_feature_dim
        self.D = args.action_emb_dim
        # 自回归预测时间j的时间嵌入
        self.time_mlp = nn.Sequential(
            SinusoidalPosEmb(args.base_ch),nn.Linear(args.base_ch, args.time_emb_dim),
            nn.SiLU(),
            nn.Linear(args.time_emb_dim, args.time_emb_dim)
        )
        self.time_emb_proj1 = nn.Sequential(nn.SiLU(), nn.Linear(args.time_emb_dim, self.Cs + self.Cd*self.T))
        self.time_emb_proj2 = nn.Sequential(nn.SiLU(),nn.Linear(args.time_emb_dim, args.base_ch))
        self.time_emb_proj3 = nn.Sequential(nn.SiLU(),nn.Linear(args.time_emb_dim, args.base_ch))
        
        # 动作嵌入与动作交叉注意力
        # 特征:[B*N, T*F]
        # 动作：[B, T, A] → [B*N, T, Cd]
        self.action_mlp = nn.Sequential(nn.Linear(args.action_dim, self.Cd),nn.SiLU(),nn.Linear(self.Cd, self.Cd))
        
        # 特征提取主干GNN网络：Polynormer
        self.attn1 = EnhancedPolynormer(in_channels=self.Cs + self.Cd*self.T, hidden_channels=args.base_ch, out_channels = args.base_ch, 
                                    local_layers = 7, global_layers = 3, heads=args.num_heads, local_attn=True, edge_dim=args.edge_dim)
        self.attn2 = EnhancedPolynormer(in_channels=args.base_ch, hidden_channels=args.base_ch, out_channels = args.base_ch, 
                                    local_layers = 7, global_layers = 3, heads=args.num_heads, local_attn=True, edge_dim=args.edge_dim)
        self.attn3 = EnhancedPolynormer(in_channels=args.base_ch, hidden_channels=args.base_ch, out_channels = args.base_ch, 
                                    local_layers = 7, global_layers = 3, heads=args.num_heads, local_attn=True, edge_dim=args.edge_dim)
        
        # 任务头
        self.risk_head = nn.Sequential(nn.Linear(args.base_ch + 24, args.base_ch), nn.SiLU(), nn.Linear(args.base_ch, 1))
        self.ego_head = nn.Sequential(nn.Linear(args.base_ch, args.base_ch), nn.SiLU(), nn.Linear(args.base_ch, 1))
        self.occ_head = nn.Sequential(nn.Linear(args.base_ch, args.base_ch), nn.SiLU(), nn.Linear(args.base_ch, 1))
        self.spd_head = nn.Sequential(nn.Linear(args.base_ch + 1, args.base_ch), nn.SiLU(), nn.Linear(args.base_ch, 1))
        self.acc_head = nn.Sequential(nn.Linear(args.base_ch + 1, args.base_ch), nn.SiLU(), nn.Linear(args.base_ch, 1))
        self.head_head = nn.Sequential(nn.Linear(args.base_ch + 1, args.base_ch), nn.SiLU(), nn.Linear(args.base_ch, 1))
        self.vtype_head = nn.Sequential(nn.Linear(args.base_ch + 1, args.base_ch), nn.SiLU(), nn.Linear(args.base_ch, 15))
        self.routes_head = nn.Sequential(nn.Linear(args.base_ch + 1, args.base_ch), nn.SiLU(), nn.Linear(args.base_ch, 4))


    def forward(self, batch):
        actions = torch.cat([batch.action_acc.unsqueeze(-1),batch.action_lc.unsqueeze(-1)],dim=2) # [B, T, A]
        actions_emb = self.action_mlp(actions).reshape(-1, self.T*self.Cd)[batch.batch,:] # [B, T, Cd] -> [B*N, T*Cd]
        # 时间编码与特征提取主干GNN网络
        static_features = batch.x[:, 2:8] # [B*N, Cs]
        dyn_features = batch.x[:,8:] #[B*N, T*Cd]  #reshape(-1, self.T, self.Cd) # [B*N, T, Cd]
        time_emb = self.time_mlp(batch.timestamp)
        batch_x = torch.cat([static_features, dyn_features + actions_emb],dim=1) + self.time_emb_proj1(time_emb)
        batch_x = F.silu(self.attn1(batch_x, batch.edge_index, batch.edge_attr))
        batch_x = batch_x + self.time_emb_proj2(time_emb)
        batch_x = F.silu(self.attn2(batch_x, batch.edge_index, batch.edge_attr))
        batch_x = batch_x + self.time_emb_proj3(time_emb)
        batch_x = F.silu(self.attn3(batch_x, batch.edge_index, batch.edge_attr))
        
        # 下游任务计算
        # 计算0-1的ego, occ 
        ego = self.ego_head(batch_x)
        occ = self.occ_head(batch_x)
        new_batch_x = torch.cat([batch_x,ego+occ],dim=1)
        ego = torch.sigmoid(ego)
        occ = torch.sigmoid(occ)
        # 取出logit的spd, acc, head
        spd = F.relu(self.spd_head(new_batch_x)) - 1
        acc = self.acc_head(new_batch_x)
        head = self.head_head(new_batch_x)
        # 计算softmax的2个分类问题(不需要手动计算softmax, 因为CrossEntropyLoss会自动计算)
        vtypes = self.vtype_head(new_batch_x)
        routes = self.routes_head(new_batch_x)
        # 根据前述信息计算0-1的risk
        total_batch_x = torch.cat([batch_x, ego,occ,head,spd,acc,routes,vtypes],dim=1)
        risk = torch.sigmoid(self.risk_head(total_batch_x))

        return risk.squeeze(), ego.squeeze(), occ.squeeze(), spd.squeeze(), acc.squeeze(), head.squeeze(), vtypes, routes
    
    