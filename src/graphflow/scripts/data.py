import os, re
import pandas as pd
import h5py
import numpy as np
import torch
from torch_geometric.data import Data
from torch_geometric.data import InMemoryDataset

class TemporalData(Data):
    def __init__(self, x=None, edge_index=None, edge_attr=None, y=None, timestamp=None, **kwargs):
        super().__init__(x=x, edge_index=edge_index, edge_attr=edge_attr, y=y, **kwargs)
        self.timestamp = timestamp

class COMPASSGraphDataset(InMemoryDataset):
    def __init__(self, root, transform=None, pre_transform=None, pre_filter=None):
        super().__init__(root, transform, pre_transform, pre_filter) # pre_filter可根据需求筛选数据
        self.load(self.processed_paths[0]) # 新版的PyG数据集加载方式
        
    @property
    def raw_file_names(self):
        # 返回指定根目录下所有以 '.mat' 结尾的文件名
        files = [f for f in os.listdir(self.raw_dir) if f.endswith('.mat')]
        return files

    @property
    def processed_file_names(self):
        return [f'compass_graphs.pt']

    def download(self):
        pass
    
    def process(self):
        data_list = []
        raw_file_names = self.raw_file_names

        for idx, raw_filename in enumerate(raw_file_names):
   
            raw_path = os.path.join(self.raw_dir, raw_filename) # 获取数据路径
            print(raw_path)
            
            graph_series = self.read_graph_sample(raw_path)

            data_list.append(graph_series)

        self.save(data_list, self.processed_paths[0])

    def read_graph_sample(self,file_rel_path,verbose=True):
        # ====================== 2. 读取数值矩阵 ======================
        with h5py.File(file_rel_path, 'r') as f:
            # --------------------------
            # 1. 读取边的源/目标节点（src/tgt，0-based数值）
            # --------------------------
            # MATLAB列优先 → Python行优先，转置+降维（去除多余维度）
            edge_index = np.squeeze(np.array(f['endNodes'])) - 1  # 转换为0-based索引

            # 转置匹配维度（MATLAB列优先→Python行优先），去除冗余维度
            nodeStatFeat = np.squeeze(np.array(f['nodeStatFeats']).T)  # 
            nodeDynFeat = np.squeeze(np.array(f['nodeDynFeats']).T)  # 
            
            # --------------------------
            # 3. 读取边特征矩阵（edgeFeat：.Variables提取的数值矩阵）
            # --------------------------
            edgeFeat = np.squeeze(np.array(f['edgeFeats']).T)  # 
            # edgeNum = np.squeeze(np.array(f['edges_num']))  #
            node_idx_list = np.squeeze(np.array(f['nodes_idx_list']))  #

        

        # ====================== 3. 转换为PyG张量（构建有向图） ======================
        # 核心要求：
        # - edge_index必须为torch.int64（PyG强制）
        # - 节点/边特征为torch.float32（深度学习常用格式）
        edge_index = torch.tensor(edge_index, dtype=torch.int64)
        # nodes_idx = np.arange(0, nodeStatFeat.shape[0]) + nodeStatFeat.shape[0]*i
        x = torch.tensor(nodeStatFeat, dtype=torch.float32)
        y = torch.tensor(nodeDynFeat, dtype=torch.float32)          # 节点特征 (N, 特征数)
        edge_attr = torch.tensor(edgeFeat, dtype=torch.float32)  # 边特征 (11645, M)
        timestamp = torch.randn(1, dtype=torch.float32)
        # 构建PyG有向图（天然支持有向，核心是edge_index的方向）
        graph_pyg = TemporalData(
            x=x,                     # 节点特征矩阵（目前只包含静态特征，需要在transform中处理添加历史和当前动态特征）
            edge_index=edge_index,   # 有向边索引（src→tgt）
            edge_attr=edge_attr,     # 边特征矩阵（.Variables提取的数值）
            y=y,                     # 节点特征矩阵（.Variables提取的数值，需要在transform中处理提取对应时间的）
            timestamp=timestamp           # 时间戳（需要在transform中处理赋值）
        )

            
        if verbose:
            file_abs_path = os.path.abspath(file_rel_path)
            # ====================== 4. 验证读取结果（匹配你的数据维度） ======================
            print("===== 读取结果 =====")
            print(f"文件路径：{file_abs_path}")
            print(f"edge_index维度：{edge_index.shape}")  # 预期 (2, 11645)
            print(f"节点特征维度：{x.shape}")            # 预期 (4301, 特征数)
            print(f"边特征维度：{edge_attr.shape}")      # 预期 (11645, 特征数)
            print(f"PyG有向图节点数：{graph_pyg.num_nodes}")  # 4301（由x的行数自动推断）
            print(f"PyG有向图边数：{graph_pyg.num_edges}")    # 11645
            print(f"是否为有向图：{graph_pyg.is_directed()}") # True
        
        return graph_pyg
            
# graph_series = read_graph_sample(file_rel_path)
