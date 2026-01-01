from data_inmemory import COMPASSGraphDataset
from utils import plot_graph
from torch_geometric.loader import DataLoader
from torch import serialization
import torch
import numpy as np
from data_inmemory import TemporalData  # 从你的data模块导入TemporalData类
serialization.add_safe_globals([TemporalData])  # 加入安全白名单,就不会报加载的警告了

def randomChooseTimeAndSlice(data: TemporalData):
    """
    从时间序列数据中随机选择一个20s内的未来时间点，然后将TemporalData的y中
    提取出历史特征cat给x,选择的未来特征切片赋值给y,并设置timestamp为未来时间点
    """
    timestamp = torch.randint(1,20,(1,)).long()
    nodes_number = data.x.shape[0]
    y_nodes_idx = torch.arange(0, nodes_number) + nodes_number*(timestamp + 20)
    for i in range(21):
        nodes_idx = torch.arange(0, nodes_number) + nodes_number*(timestamp + i)
        data.x = torch.cat([data.x, data.y[nodes_idx,:]], dim=1) # 拼接历史动态特征
    data.y = data.y[y_nodes_idx,:] # 取未来时刻标签
    data.timestamp = timestamp.clone().detach().float()  # 若timestamp是张量时用这个
    return data

    

dataset = COMPASSGraphDataset(root="data/dataset/CompassGraphDataset", transform=randomChooseTimeAndSlice)
loader = DataLoader(dataset, batch_size=15, shuffle=True)
# 枚举数据集
for step, batch in enumerate(loader):
    batch = batch.to('cuda')
    print(f"Step {step + 1}:")
    print('=============')
    print(f'Number of graphs in the current batch:{batch.num_graphs}')
    print(batch)
    print('batch.timestamp:', batch.timestamp)
    print('batch.batch:', batch.batch)
    print('batch.ptr:', batch.ptr)
    break
