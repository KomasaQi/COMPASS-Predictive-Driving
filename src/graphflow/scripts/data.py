# -*- coding: utf-8 -*-
"""
@Author: Komasa Qi
@Contact: komasaqi@foxmail.com
"""
import os
import re
import pandas as pd
import h5py
import numpy as np
import torch
import gc  # 内存回收
from torch_geometric.data import Data
from torch_geometric.data import Dataset
from torch import serialization
from sklearn.model_selection import train_test_split
from torch_geometric.loader import DataLoader


class TemporalData(Data):
    def __init__(self, x=None, edge_index=None, edge_attr=None, y=None, timestamp=None, action_acc=None, action_lc=None, **kwargs):
        super().__init__(x=x, edge_index=edge_index, edge_attr=edge_attr, y=y, **kwargs)
        self.timestamp = timestamp
        self.action_acc = action_acc
        self.action_lc = action_lc
    
        
class COMPASSGraphDataset(Dataset):
    def __init__(self, root, transform=None, pre_transform=None, pre_filter=None):
        # ====================== 修复核心1：先初始化自定义属性，再调用父类构造函数 ======================
        self.root = root
        self.raw_file_names_list = [f for f in os.listdir(self.raw_dir) if f.endswith('.mat')]
        # 仅在测试时启用，截取前256个样本，正式训练时注释掉
        self.raw_file_names_list = self.raw_file_names_list[:256]
        self.raw_file_paths = [os.path.join(self.raw_dir, f) for f in self.raw_file_names_list]
        self.raw_file_paths = [p for p in self.raw_file_paths if os.path.exists(p)]
        
        serialization.add_safe_globals([TemporalData])  # 加入安全白名单,就不会报加载的警告了
        # 2. 再调用父类构造函数（此时所有自定义属性已初始化，process可正常调用）
        super().__init__(root, transform, pre_transform, pre_filter)

    @property
    def raw_file_names(self):
        # 返回过滤后的有效文件名（与raw_file_paths一一对应）
        return [os.path.basename(p) for p in self.raw_file_paths]

    @property
    def processed_file_names(self):
        # 每个有效原始文件对应一个处理后的.pt文件
        return [f'processed_{i}.pt' for i in range(len(self.raw_file_paths))]

    def download(self):
        # 本地数据无需下载，pass即可
        pass
    
    def process(self):
        # 逐个处理、逐个保存，内存占用恒定，并加入进度显示
        total_samples = len(self.raw_file_paths)
        print(f"开始处理 {total_samples} 个样本...")
        for idx, raw_path in enumerate(self.raw_file_paths):
            try:
                if not os.path.exists(raw_path): # 二次校验文件存在性（双重保险）
                    print(f"⚠️ 文件不存在，跳过：{os.path.basename(raw_path)}")
                    continue
                
                graph_data = self.read_graph_sample(raw_path, verbose=False) # 读取单样本图数据
                
                if self.pre_filter is not None and not self.pre_filter(graph_data): # 过滤无效样本
                    continue
                
                if self.pre_transform is not None: # 应用预处理转换
                    graph_data = self.pre_transform(graph_data)
                
                torch.save([graph_data], self.processed_paths[idx])
                print(f"✅ 成功处理：{os.path.basename(raw_path)} (索引 {idx}/{total_samples}) 进度: {((idx+1)/total_samples)*100:.2f}%")
            except Exception as e:
                print(f"❌ 处理失败 {os.path.basename(raw_path)} (索引 {idx}/{total_samples}): {str(e)} 已跳过。")
            finally:
                # 每50个样本强制回收内存，缓解Windows内存碎片
                if idx % 50 == 0:
                    gc.collect()

        

    def read_graph_sample(self,file_rel_path,verbose=True):
        """
        
        # ==== 将动态特征和边特征首先进行拓展化处理，将车辆类型、道路类型和车道类型都转换为one-hot编码 ==============
        # feat_trans_name_dict = {
        #     'x': 1, 'y': 2,'node_type': 3, 'free_end': 4,
        #     'laneno': 5,'roadtype': 6, 'spdlim': 7, 'drivable': 8,
        #     'occ': 9, 'vtype': 10, 'spd': 11, 'acc': 12,
        #     'head': 13, 'ego': 14, 'route': 15, 'risk': 16
        # } # 静态特征为前8维，动态特征为后8维，共16维，动态特征中，我们需要将vtype（0~14）和route(0~3)转换为one-hot编码
        # 边特征处理前为2维，分别是：weight和distance，其中weight表示了不同的边类型，也需要转换为one-hot编码
        # next = -1.0;      % 顺着道路连接方向的边的特征
        # side_left = 2.0;  % 包含横向移动的边的特征向左
        # side_right = 1.0; % 包含横向移动的边的特征向右
        # junction = 0.0;   % 路口连接的网状结构的边的特征
        # 转换后的动态特征y维度(25维) = {
        #     'occ': 0, 'spd': 1, 'acc': 2,
        #     'head': 3, 'ego': 4, 'risk': 5, 'vtype': 6-20(one-hot,15分类), 'route': 21-24(one-hot,4分类)
        # } 
        """
        with h5py.File(file_rel_path, 'r') as f:
            # MATLAB列优先 → Python行优先，转置+降维
            edge_index = np.squeeze(np.array(f['endNodes'],dtype=np.int32)) - 1  # 0-based索引
            nodeStatFeat = np.squeeze(np.array(f['nodeStatFeats'],dtype=np.float32).T)
            nodeDynFeat = np.squeeze(np.array(f['nodeDynFeats'],dtype=np.float32).T)
            edgeFeat = np.squeeze(np.array(f['edgeFeats'],dtype=np.float32).T)
            action_acc = np.squeeze(np.array(f['action_acc'],dtype=np.float32))
            action_lc = np.squeeze(np.array(f['action_lc'],dtype=np.int32))

        # ==== 将动态特征和边特征首先进行拓展化处理，将车辆类型、道路类型和车道类型都转换为one-hot编码 ==============
        #  # 静态特征为前8维，动态特征为后8维，共16维，动态特征中，我们需要将vtype（0~14）和route(0~3)转换为one-hot编码
        nodeDynFeat_vType = nodeDynFeat[:,1]
        nodeDynFeat_vType[nodeDynFeat_vType > 14] = 14  # 限制车辆类型在[0,14]
        nodeDynFeat_route = nodeDynFeat[:,6]
        nodeDynFeat_route[nodeDynFeat_route > 3] = 3  # 限制路由索引在[0,3]
        nodeDynFeat_no_convert = torch.tensor(nodeDynFeat[:,[0,2,3,4,5,7]], dtype=torch.float32)  # 不需要转换的动态特征
        nodeDynFeat_no_convert[:,1] = (nodeDynFeat_no_convert[:,1] - 20.0) / 20.0  # 归一化动态特征中的限速spdlim
        # 转换one-hot编码
        nodeDynFeat_route_onehot = torch.nn.functional.one_hot(torch.tensor(nodeDynFeat_route, dtype=torch.long), num_classes=4).float()
        nodeDynFeat_vType_onehot = torch.nn.functional.one_hot(torch.tensor(nodeDynFeat_vType, dtype=torch.long), num_classes=15).float()
        edgeFeat_type = edgeFeat[:,0] + 1  # 将类型从[-1,2]映射到[0,3]
        edgeFeat_no_convert = torch.tensor(edgeFeat[:,1:], dtype=torch.float32)  # 不需要转换的边特征
        
        # 转换one-hot编码
        edgeFeat_type_onehot = torch.nn.functional.one_hot(torch.tensor(edgeFeat_type, dtype=torch.long), num_classes=4).float()

        # ==== 将动静态特征和边特征进行归一化处理 ==========================
        
        # ====================== edge_index维度+类型合规化（PyG强制要求）======================
        # 1. 转为 (2, E) 二维张量（PyG必须格式）、2. 转为torch.long类型（PyG强制）
        edge_index = torch.tensor(edge_index, dtype=torch.long).reshape(2, -1)
        # edge_index = torch.cat([edge_index, edge_index[[1,0],:]], dim=1)  # 无向图，添加反向边
        x = torch.tensor(nodeStatFeat, dtype=torch.float32)
        x[:,6] = (x[:,6] - 20.0) / 20.0  # 归一化静态特征中的限速spdlim
        y = torch.cat([nodeDynFeat_no_convert, nodeDynFeat_vType_onehot, nodeDynFeat_route_onehot], dim=1)
        edge_attr = torch.cat([edgeFeat_type_onehot, edgeFeat_no_convert], dim=1)
        # edge_attr = torch.cat([edge_attr, torch.cat([-edge_attr[:,:-1],edge_attr[:,-1:]],dim=1)], dim=0)  # 无向图，添加反向边的边特征
        action_acc = torch.tensor(action_acc, dtype=torch.float32).reshape(1,-1)
        action_lc = torch.tensor(action_lc, dtype=torch.long).reshape(1,-1)
        nodes_number = x.shape[0]
        hist_graph = 20  # 历史时间步数

        # 拼接历史动态特征（优化索引逻辑，避免越界）
        for i in range(hist_graph + 1):
            nodes_idx = torch.arange(0, nodes_number) + nodes_number*i
            x = torch.cat([x, y[nodes_idx,:]], dim=1)

        # 取未来时刻标签，未来20s内的动态特征
        y = y[nodes_number*(hist_graph+1):,:].reshape(20,-1,25).permute(1,2,0)
        
    

        # 构建时序图数据
        graph_pyg = TemporalData(
            x=x, 
            edge_index=edge_index, 
            edge_attr=edge_attr, 
            y=y, 
            timestamp=None,
            action_acc=action_acc,
            action_lc=action_lc
        )
            
        if verbose:
            file_abs_path = os.path.abspath(file_rel_path)
            print(f"文件路径：{file_abs_path}")
            print(f"节点数：{graph_pyg.num_nodes}, 边数：{graph_pyg.num_edges}")
            print(f"节点特征维度：{x.shape}, 边特征维度：{edge_attr.shape}")

        return graph_pyg
    
    def len(self):
        # 返回有效样本数（过滤后）
        return len(self.raw_file_paths)
    
    def get(self, idx):
        # ======================使用torch.load ======================
        data = torch.load(self.processed_paths[idx],weights_only=False)[0]
        return data
    


    

def randomChooseTimeAndSlice(data: TemporalData):
    """
    从时间序列数据中随机选择一个20s内的未来时间点，然后将选择的未来特征切片赋值给y,并设置timestamp为未来时间点
    """
    # timestamp = torch.randint(1,21,(1,)).long()
    timestamp = torch.randint(1,2,(1,)).long()
    nodes_number = data.x.shape[0]
    y_nodes_idx = torch.arange(0, nodes_number) + nodes_number*(timestamp - 1)
    data.y = data.y[y_nodes_idx,:] # 取未来时刻标签
    data.timestamp = timestamp.clone().detach().float()  # 若timestamp是张量时用这个
    return data


def load_compass_data(args):
    # dataset = COMPASSGraphDataset(root="data/dataset/CompassGraphDataset", transform=randomChooseTimeAndSlice)
    dataset = COMPASSGraphDataset(root="data/dataset/CompassGraphDataset") # 不适用tranform，没有timestamp,y为未来20s的标签

    # 80%的样本用于训练，20%用于验证和测试
    # train_dataset, test_dataset = train_test_split(dataset, test_size=0.2, random_state=args.seed)
    # train_loader = DataLoader(train_dataset, batch_size=args.train_batch_size, shuffle=True, num_workers=4)
    # test_loader = DataLoader(test_dataset, batch_size=args.train_batch_size, shuffle=False, num_workers=4)
    
    train_loader = DataLoader(dataset, batch_size=args.train_batch_size, shuffle=True, num_workers=0)
    

    return train_loader, train_loader, dataset.num_node_features, dataset.num_edge_features