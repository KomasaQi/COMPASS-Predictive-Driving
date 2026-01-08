from typing import Optional
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch_geometric.nn import GATConv, GCNConv, GATv2Conv, TransformerConv, PerformerAttention, SGFormerAttention
from torch import Tensor
from torch_geometric.nn.attention import PolynormerAttention
from torch_geometric.utils import to_dense_batch
import math

    
class EnhancedPolynormer(torch.nn.Module):
    r"""The polynormer module from the
    `"Polynormer: polynomial-expressive graph
    transformer in linear time"
    <https://arxiv.org/abs/2403.01232>`_ paper. 
    and with Komasa's enhancement on supporting
    edge features.

    Args:
        in_channels (int): Input channels.
        hidden_channels (int): Hidden channels.
        out_channels (int): Output channels.
        local_layers (int): The number of local attention layers.
            (default: :obj:`7`)
        global_layers (int): The number of global attention layers.
            (default: :obj:`2`)
        in_dropout (float): Input dropout rate.
            (default: :obj:`0.15`)
        dropout (float): Dropout rate.
            (default: :obj:`0.5`)
        global_dropout (float): Global dropout rate.
            (default: :obj:`0.5`)
        heads (int): The number of heads.
            (default: :obj:`1`)
        beta (float): Aggregate type.
            (default: :obj:`0.9`)
        qk_shared (bool optional): Whether weight of query and key are shared.
            (default: :obj:`True`)
        pre_ln (bool): Pre layer normalization.
            (default: :obj:`False`)
        post_bn (bool): Post batch normalization.
            (default: :obj:`True`)
        local_attn (bool): Whether use local attention.
            (default: :obj:`False`)
    """
    def __init__(
        self,
        in_channels: int,
        hidden_channels: int,
        out_channels: int,
        local_layers: int = 7,
        global_layers: int = 2,
        in_dropout: float = 0.15,
        dropout: float = 0.5,
        global_dropout: float = 0.5,
        edge_dim: int = None,
        heads: int = 1,
        beta: float = 0.9,
        qk_shared: bool = False,
        pre_ln: bool = False,
        post_bn: bool = True,
        local_attn: bool = False,
    ) -> None:
        super().__init__()
        self._global = False
        self.in_drop = in_dropout
        self.dropout = dropout
        self.pre_ln = pre_ln
        self.post_bn = post_bn

        self.beta = beta

        self.h_lins = torch.nn.ModuleList()
        self.local_convs = torch.nn.ModuleList()
        self.lins = torch.nn.ModuleList()
        self.lns = torch.nn.ModuleList()
        if self.pre_ln:
            self.pre_lns = torch.nn.ModuleList()
        if self.post_bn:
            self.post_bns = torch.nn.ModuleList()

        # first layer
        inner_channels = heads * hidden_channels
        self.h_lins.append(torch.nn.Linear(in_channels, inner_channels))
        if local_attn:
            self.local_convs.append(
                GATv2Conv(in_channels, hidden_channels, heads=heads, concat=True,
                        add_self_loops=False, bias=False, edge_dim=edge_dim))
        else:
            self.local_convs.append(
                GCNConv(in_channels, inner_channels, cached=False,
                        normalize=True))

        self.lins.append(torch.nn.Linear(in_channels, inner_channels))
        self.lns.append(torch.nn.LayerNorm(inner_channels))
        if self.pre_ln:
            self.pre_lns.append(torch.nn.LayerNorm(in_channels))
        if self.post_bn:
            self.post_bns.append(torch.nn.BatchNorm1d(inner_channels))

        # following layers
        for _ in range(local_layers - 1):
            self.h_lins.append(torch.nn.Linear(inner_channels, inner_channels))
            if local_attn:
                self.local_convs.append(
                    GATv2Conv(inner_channels, hidden_channels, heads=heads,
                            concat=True, add_self_loops=False, bias=False, edge_dim=edge_dim))
            else:
                self.local_convs.append(
                    GCNConv(inner_channels, inner_channels, cached=False,
                            normalize=True))

            self.lins.append(torch.nn.Linear(inner_channels, inner_channels))
            self.lns.append(torch.nn.LayerNorm(inner_channels))
            if self.pre_ln:
                self.pre_lns.append(torch.nn.LayerNorm(heads *
                                                       hidden_channels))
            if self.post_bn:
                self.post_bns.append(torch.nn.BatchNorm1d(inner_channels))

        self.lin_in = torch.nn.Linear(in_channels, inner_channels)
        self.ln = torch.nn.LayerNorm(inner_channels)

        self.global_attn = torch.nn.ModuleList()
        for _ in range(global_layers):
            self.global_attn.append(
                PolynormerAttention(
                    channels=hidden_channels,
                    heads=heads,
                    head_channels=hidden_channels,
                    beta=beta,
                    dropout=global_dropout,
                    qk_shared=qk_shared,
                ))
        self.pred_local = torch.nn.Linear(inner_channels, out_channels)
        self.pred_global = torch.nn.Linear(inner_channels, out_channels)
        self.reset_parameters()

    def reset_parameters(self) -> None:
        for local_conv in self.local_convs:
            local_conv.reset_parameters()
        for attn in self.global_attn:
            attn.reset_parameters()
        for lin in self.lins:
            lin.reset_parameters()
        for h_lin in self.h_lins:
            h_lin.reset_parameters()
        for ln in self.lns:
            ln.reset_parameters()
        if self.pre_ln:
            for p_ln in self.pre_lns:
                p_ln.reset_parameters()
        if self.post_bn:
            for p_bn in self.post_bns:
                p_bn.reset_parameters()
        self.lin_in.reset_parameters()
        self.ln.reset_parameters()
        self.pred_local.reset_parameters()
        self.pred_global.reset_parameters()

    def forward(
        self,
        x: Tensor,
        edge_index: Tensor,
        batch: Optional[Tensor],
        edge_attr: Optional[Tensor] = None,
    ) -> Tensor:
        r"""Forward pass.

        Args:
            x (torch.Tensor): The input node features.
            edge_index (torch.Tensor or SparseTensor): The edge indices.
            batch (torch.Tensor, optional): The batch vector
                :math:`\mathbf{b} \in {\{ 0, \ldots, B-1\}}^N`, which assigns
                each element to a specific example.
        """
        x = F.dropout(x, p=self.in_drop, training=self.training)

        # equivariant local attention
        x_local = 0
        for i, local_conv in enumerate(self.local_convs):
            if self.pre_ln:
                x = self.pre_lns[i](x)
            h = self.h_lins[i](x)
            h = F.relu(h)
            x = local_conv(x, edge_index, edge_attr) + self.lins[i](x)
            if self.post_bn:
                x = self.post_bns[i](x)
            x = F.relu(x)
            x = F.dropout(x, p=self.dropout, training=self.training)
            x = (1 - self.beta) * self.lns[i](h * x) + self.beta * x
            x_local = x_local + x

        # equivariant global attention
        if self._global:
            batch, indices = batch.sort()
            rev_perm = torch.empty_like(indices)
            rev_perm[indices] = torch.arange(len(indices),
                                             device=indices.device)
            x_local = self.ln(x_local[indices])
            x_global, mask = to_dense_batch(x_local, batch)
            for attn in self.global_attn:
                x_global = attn(x_global, mask)
            x = x_global[mask][rev_perm]
            x = self.pred_global(x)
        else:
            x = self.pred_local(x_local)

        # return F.log_softmax(x, dim=-1)
        return x



class GraphModule(torch.nn.Module):
    def __init__(
        self,
        in_channels,
        hidden_channels,
        num_layers=2,
        dropout=0.5,
        edge_dim: int = None,
    ):
        super().__init__()

        self.convs = torch.nn.ModuleList()
        self.fcs = torch.nn.ModuleList()
        self.fcs.append(torch.nn.Linear(in_channels, hidden_channels))

        self.bns = torch.nn.ModuleList()
        self.bns.append(torch.nn.BatchNorm1d(hidden_channels))
        for _ in range(num_layers):
            self.convs.append(GATv2Conv(hidden_channels, hidden_channels, edge_dim=edge_dim))
            self.bns.append(torch.nn.BatchNorm1d(hidden_channels))

        self.dropout = dropout
        self.activation = F.relu

    def reset_parameters(self):
        for conv in self.convs:
            conv.reset_parameters()
        for bn in self.bns:
            bn.reset_parameters()
        for fc in self.fcs:
            fc.reset_parameters()

    def forward(self, x, edge_index, edge_attr: Optional[Tensor] = None):
        x = self.fcs[0](x)
        x = self.bns[0](x)
        x = self.activation(x)
        x = F.dropout(x, p=self.dropout, training=self.training)
        last_x = x

        for i, conv in enumerate(self.convs):
            x = conv(x, edge_index, edge_attr)
            x = self.bns[i + 1](x)
            x = self.activation(x)
            x = F.dropout(x, p=self.dropout, training=self.training)
            x = x + last_x
        return x


class SGModule(torch.nn.Module):
    def __init__(
        self,
        in_channels,
        hidden_channels,
        num_layers=2,
        num_heads=1,
        dropout=0.5,
    ):
        super().__init__()

        self.attns = torch.nn.ModuleList()
        self.fcs = torch.nn.ModuleList()
        self.fcs.append(torch.nn.Linear(in_channels, hidden_channels))
        self.bns = torch.nn.ModuleList()
        self.bns.append(torch.nn.LayerNorm(hidden_channels))
        for _ in range(num_layers):
            self.attns.append(
                SGFormerAttention(hidden_channels, num_heads, hidden_channels))
            self.bns.append(torch.nn.LayerNorm(hidden_channels))

        self.dropout = dropout
        self.activation = F.relu

    def reset_parameters(self):
        for attn in self.attns:
            attn.reset_parameters()
        for bn in self.bns:
            bn.reset_parameters()
        for fc in self.fcs:
            fc.reset_parameters()

    def forward(self, x: Tensor, batch: Tensor):
        # to dense batch expects sorted batch
        batch, indices = batch.sort(stable=True)
        rev_perm = torch.empty_like(indices)
        rev_perm[indices] = torch.arange(len(indices), device=indices.device)
        x = x[indices]
        x, mask = to_dense_batch(x, batch)
        layer_ = []

        # input MLP layer
        x = self.fcs[0](x)
        x = self.bns[0](x)
        x = self.activation(x)
        x = F.dropout(x, p=self.dropout, training=self.training)

        # store as residual link
        layer_.append(x)

        for i, attn in enumerate(self.attns):
            x = attn(x, mask)
            x = (x + layer_[i]) / 2.
            x = self.bns[i + 1](x)
            x = self.activation(x)
            x = F.dropout(x, p=self.dropout, training=self.training)
            layer_.append(x)

        x_mask = x[mask]
        # reverse the sorting
        unsorted_x_mask = x_mask[rev_perm]
        return unsorted_x_mask


class EnhancedSGFormer(torch.nn.Module):
    r"""The sgformer module from the
    `"SGFormer: Simplifying and Empowering Transformers for
    Large-Graph Representations"
    <https://arxiv.org/abs/2306.10759>`_ paper.

    Args:
        in_channels (int): Input channels.
        hidden_channels (int): Hidden channels.
        out_channels (int): Output channels.
        trans_num_layers (int): The number of layers for all-pair attention.
            (default: :obj:`2`)
        trans_num_heads (int): The number of heads for attention.
            (default: :obj:`1`)
        trans_dropout (float): Global dropout rate.
            (default: :obj:`0.5`)
        gnn_num_layers (int): The number of layers for GNN.
            (default: :obj:`3`)
        gnn_dropout (float): GNN dropout rate.
            (default: :obj:`0.5`)
        graph_weight (float): The weight balance global and gnn module.
            (default: :obj:`0.5`)
        aggregate (str): Aggregate type.
            (default: :obj:`add`)
    """
    def __init__(
        self,
        in_channels: int,
        hidden_channels: int,
        out_channels: int,
        trans_num_layers: int = 2,
        trans_num_heads: int = 1,
        trans_dropout: float = 0.5,
        gnn_num_layers: int = 3,
        gnn_dropout: float = 0.5,
        graph_weight: float = 0.5,
        aggregate: str = 'add',
        edge_dim: int = None,
    ):
        super().__init__()
        self.trans_conv = SGModule(
            in_channels,
            hidden_channels,
            trans_num_layers,
            trans_num_heads,
            trans_dropout,
        )
        self.graph_conv = GraphModule(
            in_channels,
            hidden_channels,
            gnn_num_layers,
            gnn_dropout,
            edge_dim=edge_dim,
        )
        self.graph_weight = graph_weight

        self.aggregate = aggregate

        if aggregate == 'add':
            self.fc = torch.nn.Linear(hidden_channels, out_channels)
        elif aggregate == 'cat':
            self.fc = torch.nn.Linear(2 * hidden_channels, out_channels)
        else:
            raise ValueError(f'Invalid aggregate type:{aggregate}')

        self.params1 = list(self.trans_conv.parameters())
        self.params2 = list(self.graph_conv.parameters())
        self.params2.extend(list(self.fc.parameters()))

        self.out_channels = out_channels

    def reset_parameters(self) -> None:
        self.trans_conv.reset_parameters()
        self.graph_conv.reset_parameters()
        self.fc.reset_parameters()

    def forward(
        self,
        x: Tensor,
        edge_index: Tensor,
        batch: Optional[Tensor],
        edge_attr: Optional[Tensor] = None,
    ) -> Tensor:
        r"""Forward pass.

        Args:
            x (torch.Tensor): The input node features.
            edge_index (torch.Tensor or SparseTensor): The edge indices.
            batch (torch.Tensor, optional): The batch vector
                :math:`\mathbf{b} \in {\{ 0, \ldots, B-1\}}^N`, which assigns
                each element to a specific example.
        """
        x1 = self.trans_conv(x, batch)
        x2 = self.graph_conv(x, edge_index, edge_attr)
        if self.aggregate == 'add':
            x = self.graph_weight * x2 + (1 - self.graph_weight) * x1
        else:
            x = torch.cat((x1, x2), dim=1)
        x = self.fc(x)
        # return F.log_softmax(x, dim=-1)
        return x
