import torch
import torch.nn as nn
import torch.nn.functional as F
from natten import NeighborhoodAttention1D  # 1D邻域注意力（只关注序列局部邻域，比全局注意力快）
from timm.layers import DropPath  # 随机深度（正则化，防止过拟合）


class NATSequenceEncoder(nn.Module):
    """
    NAT序列编码器：处理1D序列数据（如智能体历史轨迹），核心是「多尺度邻域注意力 + FPN特征融合」
    输入：[B, C, T] → 批次×特征通道×序列长度（比如智能体轨迹：B=16, C=9, T=20）
    输出：[B, n] → 批次×最终特征维度（比如n=128，取FPN融合后最后一个时间步的特征）
    """
    def __init__(
        self,
        in_chans=24,          # 输入特征通道数（比如智能体轨迹是9维→in_chans=9）
        embed_dim=32,        # 初始嵌入维度（第一层的特征维度）
        mlp_ratio=3,         # MLP的隐藏层维度倍率（隐藏层=dim×mlp_ratio）
        kernel_size=[3, 3, 5],  # 各层级邻域注意力的核大小（关注的局部序列长度）
        depths=[2, 2, 2],    # 各层级堆叠的NATLayer数量（3层→3个尺度）
        num_heads=[2, 4, 8], # 各层级注意力头数（维度越高，头数越多）
        out_indices=[0, 1, 2], # 要输出的层级索引（3个尺度都输出，用于FPN融合）
        drop_rate=0.0,       # 全连接层dropout率
        drop_path_rate=0.2,  # DropPath率（随机深度）
        norm_layer=nn.LayerNorm,  # 归一化层类型
    ) -> None:
        super().__init__()

        # 1. 卷积Tokenizer：把原始1D序列（B,C,T）转换成嵌入（B,T,embed_dim）
        self.embed = ConvTokenizer(in_chans, embed_dim)
        self.num_levels = len(depths)  # 多尺度层级数（这里是3）
        # 各层级的特征维度：embed_dim×2^i（32→64→128）
        self.num_features = [int(embed_dim * 2**i) for i in range(self.num_levels)]
        self.out_indices = out_indices  # 要参与FPN融合的层级

        # 生成DropPath率：从0到drop_path_rate线性分布（不同层用不同率，正则化更优）
        dpr = [x.item() for x in torch.linspace(0, drop_path_rate, sum(depths))]
        self.levels = nn.ModuleList()  # 存储各尺度的NATBlock
        for i in range(self.num_levels):
            level = NATBlock(
                dim=int(embed_dim * 2**i),          # 当前层级特征维度（32/64/128）
                depth=depths[i],                    # 堆叠的NATLayer数量（2层）
                num_heads=num_heads[i],             # 注意力头数（2/4/8）
                kernel_size=kernel_size[i],         # 邻域注意力核大小（3/3/5）
                dilations=None,                     # 膨胀率（None=无膨胀）
                mlp_ratio=mlp_ratio,                # MLP倍率
                drop=drop_rate,                     # dropout率
                # 分配当前层级的DropPath率（按depths分段）
                drop_path=dpr[sum(depths[:i]) : sum(depths[: i + 1])],
                norm_layer=norm_layer,              # 归一化层
                downsample=(i < self.num_levels - 1),  # 除最后一层外，都下采样（提升维度+缩短序列）
            )
            self.levels.append(level)

        # 为每个输出层级添加归一化层（存储为self.norm0/self.norm1/self.norm2）
        for i_layer in self.out_indices:
            layer = norm_layer(self.num_features[i_layer])
            layer_name = f"norm{i_layer}"
            self.add_module(layer_name, layer)

        # 2. FPN横向连接：把各层级特征统一到最高维度（最后一层维度n=128）
        n = self.num_features[-1]  # 最高层级维度（128）
        self.lateral_convs = nn.ModuleList()  # 横向卷积（把各层级维度转成n）
        for i_layer in self.out_indices:
            self.lateral_convs.append(
                nn.Conv1d(self.num_features[i_layer], n, 3, padding=1)  # 1D卷积，保持长度不变, padding = 1表示在序列两端填充1个元素
            ) # Lout = (Lin + 2*padding - dilation*(kernel_size-1))/stride

        # FPN最终融合卷积（细化融合后的特征）
        self.fpn_conv = nn.Conv1d(n, n, 3, padding=1)

    def forward(self, x):
        """
        前向传播：多尺度编码 → FPN融合 → 输出最后一个时间步特征
        x: [B, C, T] → 比如[16,9,20]（智能体历史轨迹：16批，9维特征，20时间步）
        """
        # 步骤1：卷积Tokenize → [B,C,T] → [B,T,embed_dim]（比如[16,20,32]）
        x = self.embed(x)

        out = []  # 存储各输出层级的特征
        for idx, level in enumerate(self.levels):
            # 步骤2：各层级NATBlock编码
            # x：下采样后的特征（供下一层级用）；xo：当前层级未下采样的特征（供FPN用）
            x, xo = level(x)   
            # 如果是输出层级，归一化后加入out
            if idx in self.out_indices:
                norm_layer = getattr(self, f"norm{idx}")  # 获取self.norm0/1/2
                x_out = norm_layer(xo)  # 归一化 → [B,T_i,dim_i]（比如第一层：[16,20,32]）
                # 维度变换：[B,T_i,dim_i] → [B,dim_i,T_i]（适配Conv1d输入）
                out.append(x_out.permute(0, 2, 1).contiguous())

        # 步骤3：FPN横向连接 + 自上而下融合
        # 3.1 横向卷积：把各层级特征转成最高维度n → [B,n,T_i]
        laterals = [
            lateral_conv(out[i]) for i, lateral_conv in enumerate(self.lateral_convs)
        ]
        # 3.2 自上而下融合（从最高层到最低层，上采样+相加）
        for i in range(len(out) - 1, 0, -1): # range产生的是：[2,1]
            # 上采样高层特征到低层长度 → 与低层特征相加（融合全局+局部）
            laterals[i - 1] = laterals[i - 1] + F.interpolate(
                laterals[i],
                scale_factor=(laterals[i - 1].shape[-1] / laterals[i].shape[-1]),  # 缩放因子（匹配长度）
                mode="linear",  # 1D线性插值（适合序列）
                align_corners=False,
            )

        # 3.3 FPN最终卷积 → [B,n,T_0]（比如[16,128,20]）
        out = self.fpn_conv(laterals[0])

        # 步骤4：取最后一个时间步的特征 → [B,n]（比如[16,128]）
        return out[:, :, -1]


class ConvTokenizer(nn.Module):
    """
    卷积Tokenizer：把1D序列（B,C,T）转换成嵌入（B,T,embed_dim）
    核心：用1D卷积做特征映射，替代简单的线性层，捕捉序列局部特征
    """
    def __init__(self, in_chans=3, embed_dim=32, norm_layer=None):
        super().__init__()
        # 1D卷积：输入通道in_chans → 输出通道embed_dim，核3，步1，padding1（保持序列长度不变）
        self.proj = nn.Conv1d(in_chans, embed_dim, kernel_size=3, stride=1, padding=1) # 标准输入：[B,C,T]，输出：[B,embed_dim,T]
        # 可选归一化层
        if norm_layer is not None:
            self.norm = norm_layer(embed_dim)
        else:
            self.norm = None

    def forward(self, x):
        """
        x: [B,C,T] → 比如[16,9,20]
        输出：[B,T,embed_dim] → 比如[16,20,32]
        """
        # 卷积 → [B,embed_dim,T]
        x = self.proj(x)
        # 维度变换：[B,embed_dim,T] → [B,T,embed_dim]（适配后续注意力层）
        x = x.permute(0, 2, 1)
        # 可选归一化
        if self.norm is not None:
            x = self.norm(x)
        return x


class ConvDownsampler(nn.Module):
    """
    卷积下采样器：
    1. 特征维度翻倍（dim → 2*dim）；
    2. 序列长度减半（T → T//2）；
    用于多尺度编码的层级间下采样
    """
    def __init__(self, dim, norm_layer=nn.LayerNorm):
        super().__init__()
        # 1D卷积：dim→2*dim，核3，步2，padding1（长度减半，维度翻倍）
        self.reduction = nn.Conv1d(
            dim, 2 * dim, kernel_size=3, stride=2, padding=1, bias=False
        ) # Lout = (Lin + 2*padding - dilation*(kernel_size-1))/stride
        #  = (20 + 2*1 - 1*2)/(2) = 10 (第一次)
        # 由于stride=2，所以长度减半
        self.norm = norm_layer(2 * dim)  # 归一化层

    def forward(self, x):
        """
        x: [B,T,dim] → 比如[16,20,32]
        输出：[B,T//2,2*dim] → 比如[16,10,64]
        """
        # 维度变换：[B,T,dim] → [B,dim,T]（适配Conv1d）
        x = x.permute(0, 2, 1)
        # 卷积下采样 → [B,2*dim,T//2]
        x = self.reduction(x)
        # 维度变换还原 → [B,T//2,2*dim]
        x = x.permute(0, 2, 1)
        # 归一化
        x = self.norm(x)
        return x


class Mlp(nn.Module):
    """
    前馈网络（MLP）：注意力层后做非线性特征变换
    结构：Linear → GELU → Dropout → Linear → Dropout
    """
    def __init__(
        self,
        in_features,      # 输入维度
        hidden_features=None,  # 隐藏层维度（默认=in_features）
        out_features=None,     # 输出维度（默认=in_features）
        act_layer=nn.GELU,     # 激活函数（GELU比ReLU更平滑）
        drop=0.0,              # dropout率
    ):
        super().__init__()
        out_features = out_features or in_features
        hidden_features = hidden_features or in_features
        self.fc1 = nn.Linear(in_features, hidden_features)  # 升维
        self.act = act_layer()  # 激活
        self.fc2 = nn.Linear(hidden_features, out_features)  # 降维
        self.drop = nn.Dropout(drop)  # dropout

    def forward(self, x):
        """
        x: [B,T,dim] → 比如[16,20,32]
        输出：[B,T,dim]（维度不变，特征变换）
        """
        x = self.fc1(x)    # [B,T,hidden]
        x = self.act(x)    # 激活
        x = self.drop(x)   # dropout
        x = self.fc2(x)    # [B,T,dim]
        x = self.drop(x)   # dropout
        return x


class NATLayer(nn.Module):
    """
    单个NAT层：邻域注意力（NAT） + MLP + 残差连接
    核心：只关注序列的局部邻域（比如核3→每个位置只看前后1个位置），比全局注意力快
    """
    def __init__(
        self,
        dim,               # 特征维度（比如32/64/128）
        num_heads,         # 注意力头数
        kernel_size=7,     # 邻域注意力核大小（局部关注的序列长度,必须是奇数,如7就关注本位置+前后3个位置）
        dilation=None,     # 膨胀率（None=1，即无膨胀）
        mlp_ratio=4.0,     # MLP隐藏层倍率
        qkv_bias=True,     # QKV是否加偏置
        qk_scale=None,     # QK缩放因子（None=自动计算）
        drop=0.0,          # dropout率
        drop_path=0.0,     # DropPath率（随机深度）
        act_layer=nn.GELU, # 激活函数
        norm_layer=nn.LayerNorm,  # 归一化层
    ):
        super().__init__()
        self.dim = dim
        self.num_heads = num_heads
        self.mlp_ratio = mlp_ratio

        self.norm1 = norm_layer(dim)  # 注意力前归一化
        # 1D邻域注意力（NAT）：只关注局部邻域，速度远快于全局自注意力
        self.attn = NeighborhoodAttention1D(
            dim,
            kernel_size=kernel_size,
            dilation=dilation,
            num_heads=num_heads,
            qkv_bias=qkv_bias,
            qk_scale=qk_scale,
            proj_drop=drop,
        )

        # DropPath：随机深度（训练时随机跳过某些层，防止过拟合）
        self.drop_path = DropPath(drop_path) if drop_path > 0.0 else nn.Identity()
        self.norm2 = norm_layer(dim)  # MLP前归一化
        # 初始化MLP
        self.mlp = Mlp(
            in_features=dim,
            hidden_features=int(dim * mlp_ratio),
            act_layer=act_layer,
            drop=drop,
        )

    def forward(self, x):
        """
        x: [B,T,dim] → 比如[16,20,32]
        输出：[B,T,dim]（残差连接，维度不变）
        """
        shortcut = x  # 残差连接的捷径
        # 步骤1：归一化 + 邻域注意力
        x = self.norm1(x)    # 归一化
        x = self.attn(x)     # 邻域注意力 → [B,T,dim]
        # 步骤2：残差 + DropPath
        x = shortcut + self.drop_path(x)
        # 步骤3：归一化 + MLP + 残差 + DropPath
        x = x + self.drop_path(self.mlp(self.norm2(x)))
        return x


class NATBlock(nn.Module):
    """
    NAT块：堆叠多个NATLayer + 可选下采样
    输出：x（下采样后的特征，供下一层级用）、xo（当前层级未下采样的特征，供FPN用）
    """
    def __init__(
        self,
        dim,               # 输入特征维度
        depth,             # 堆叠的NATLayer数量
        num_heads,         # 注意力头数
        kernel_size,       # 邻域注意力核大小
        dilations=None,    # 膨胀率
        downsample=True,   # 是否下采样
        mlp_ratio=4.0,     # MLP倍率
        qkv_bias=True,     # QKV偏置
        qk_scale=None,     # QK缩放
        drop=0.0,          # dropout率
        drop_path=0.0,     # DropPath率
        norm_layer=nn.LayerNorm,  # 归一化层
        act_layer=nn.GELU, # 激活函数
    ):
        super().__init__()
        self.dim = dim
        self.depth = depth

        # 堆叠depth个NATLayer
        self.blocks = nn.ModuleList(
            [
                NATLayer(
                    dim=dim,
                    num_heads=num_heads,
                    kernel_size=kernel_size,
                    dilation=None if dilations is None else dilations[i],
                    mlp_ratio=mlp_ratio,
                    qkv_bias=qkv_bias,
                    qk_scale=qk_scale,
                    drop=drop,
                    # 每个NATLayer分配不同的DropPath率（如果是列表）
                    drop_path=drop_path[i] if isinstance(drop_path, list) else drop_path,
                    norm_layer=norm_layer,
                    act_layer=act_layer,
                )
                for i in range(depth)
            ]
        )

        # 下采样模块（ConvDownsampler）：维度翻倍，长度减半
        self.downsample = (
            None if not downsample else ConvDownsampler(dim=dim, norm_layer=norm_layer)
        )

    def forward(self, x):
        """
        x: [B,T,dim] → 比如[16,20,32]
        输出：
            x：下采样后的特征（比如[16,10,64]），供下一层级用；
            xo：当前层级未下采样的特征（[16,20,32]），供FPN用。
        """
        # 步骤1：堆叠NATLayer编码
        for blk in self.blocks:
            x = blk(x)
        xo = x  # 保存当前层级未下采样的特征（供FPN）
        # 步骤2：可选下采样
        if self.downsample is not None:
            x = self.downsample(x)
        # 最后一层无下采样 → x=xo
        return x, xo


class PointsEncoder(nn.Module):
    """
    点集编码器：处理离散点云/参考线点集（比如车道线的3D坐标点），提取全局特征
    输入：点集x [B,M,3]（B批，M个点，3维坐标） + 掩码mask [B,M]（有效点标记）
    输出：全局特征 [B,C]（C=encoder_channel，比如128）
    """
    def __init__(self, feat_channel, encoder_channel):
        super().__init__()
        self.encoder_channel = encoder_channel  # 输出特征维度（比如128）
        # 第一个MLP：把3维坐标→256维
        self.first_mlp = nn.Sequential(
            nn.Linear(feat_channel, 128),   # [B,M,3] → [B,M,128]
            nn.BatchNorm1d(128),            # 批归一化（按特征维度归一化）
            nn.ReLU(inplace=True),          # 激活
            nn.Linear(128, 256),            # [B,M,128] → [B,M,256]
        )
        # 第二个MLP：融合全局池化特征→encoder_channel维
        self.second_mlp = nn.Sequential(
            nn.Linear(512, 256),            # [B,M,512] → [B,M,256]
            nn.BatchNorm1d(256),            # 批归一化
            nn.ReLU(inplace=True),          # 激活
            nn.Linear(256, self.encoder_channel), # [B,M,256] → [B,M,C]
        )

    def forward(self, x, mask=None):
        """
        x : [B,M,3] → 离散点集（比如参考线的点）
        mask: [B,M] → 有效点掩码（True=有效点，False=无效/填充点）
        输出：feature_global : [B,C] → 点集的全局特征
        """
        bs, n, _ = x.shape  # B=批次，n=点数，_=3（坐标维度）
        device = x.device

        # 步骤1：只处理有效点，第一个MLP编码 → [有效点数,256]
        x_valid = self.first_mlp(x[mask])  # x[mask] → [有效点数,3] → [有效点数,256]
        # 初始化全0特征，把有效点的编码结果填回去 → [B,n,256]
        x_features = torch.zeros(bs, n, 256, device=device)
        x_features[mask] = x_valid

        # 步骤2：全局最大池化 → 提取点集的全局特征 [B,256]
        pooled_feature = x_features.max(dim=1)[0]
        # 拼接：每个点的特征 + 全局特征 → [B,n,256+256=512]
        x_features = torch.cat(
            [x_features, pooled_feature.unsqueeze(1).repeat(1, n, 1)], dim=-1
        )

        # 步骤3：只处理有效点，第二个MLP编码 → [有效点数,C]
        x_features_valid = self.second_mlp(x_features[mask])
        # 初始化全0特征，填回有效点结果 → [B,n,C]
        res = torch.zeros(bs, n, self.encoder_channel, device=device)
        res[mask] = x_features_valid

        # 步骤4：全局最大池化 → 点集的最终全局特征 [B,C]
        res = res.max(dim=1)[0]
        return res
    