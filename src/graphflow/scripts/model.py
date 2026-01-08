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
        self.time_mlp = nn.Sequential(
            SinusoidalPosEmb(args.base_ch),
            nn.Linear(args.base_ch, args.time_emb_dim),
            nn.SiLU(),
            nn.Linear(args.time_emb_dim, args.time_emb_dim)
        )
        # self.time_emb_proj1 = nn.Linear(args.time_emb_dim, num_node_features-2)
        self.attn1 = EnhancedPolynormer(in_channels=num_node_features-2, hidden_channels=args.base_ch*2, out_channels = args.base_ch, 
                                    local_layers = 7, global_layers = 3, heads=args.num_heads, local_attn=True, edge_dim=args.edge_dim)
        # self.time_emb_proj2 = nn.Linear(args.time_emb_dim, args.base_ch)
        self.attn2 = EnhancedPolynormer(in_channels=args.base_ch, hidden_channels=args.base_ch*2, out_channels = args.base_ch, 
                                    local_layers = 7, global_layers = 3, heads=args.num_heads, local_attn=True, edge_dim=args.edge_dim)
        # self.time_emb_proj3 = nn.Linear(args.time_emb_dim, args.base_ch)
        self.attn3 = EnhancedPolynormer(in_channels=args.base_ch, hidden_channels=args.base_ch*2, out_channels = args.base_ch, 
                                    local_layers = 7, global_layers = 3, heads=args.num_heads, local_attn=True, edge_dim=args.edge_dim)
        
        self.ouput = EnhancedSGFormer(in_channels=args.base_ch, hidden_channels=args.base_ch*2,out_channels=args.output_dim,
                                            trans_num_layers= 2, trans_num_heads=args.num_heads, edge_dim=args.edge_dim)
   


    def forward(self, batch):
        # time_emb = self.time_mlp(batch.timestamp)
        batch_x = F.silu(self.attn1(batch.x[:,2:], batch.edge_index, batch.edge_attr))
        batch_x = F.silu(self.attn2(batch_x, batch.edge_index, batch.edge_attr))
        batch_x = F.silu(self.attn3(batch_x, batch.edge_index, batch.edge_attr))
        logits_x = self.ouput(batch_x, batch.edge_index, batch.batch, batch.edge_attr)

        return batch_x
    
    