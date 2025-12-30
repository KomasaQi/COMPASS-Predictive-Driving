import matplotlib.pyplot as plt
import numpy as np
import torch

def plot_graph(graph_pyg, feature, cmap_style="viridis", node_display_size=3, plot_alpha=0.9):
    feat_trans_name_dict = {
        'x': 1, 'y': 2,
        'node_type': 3, 'free_end': 4, 'laneno': 5,
        'roadtype': 6, 'spdlim': 7, 'drivable': 8,
        'occ': 9, 'vtype': 10, 'spd': 11, 'speed': 11,
        'acc': 12, 'head': 13,'heading':13, 'ego': 14, 'route': 15
    }
    # ====================== 1. 核心配置区（⭐ 改这里即可切换特征/配色，按需修改） ======================
    # ✅ 选择要映射颜色的特征（填写【MATLAB索引】即可，自动转Python索引）
    # 对应规则：MATLAB 1(x)、2(y)、3(node_type)、4(free_end)、5(laneno)、6(roadtype)、7(spdlim)、8(drivable)
    #           MATLAB 9(occ)、10(vType)、11(spd)、12(acc)、13(head)、14(ego)、15(route)
    if feature in feat_trans_name_dict:
        color_map_matlab_idx = feat_trans_name_dict[feature] # 示例：选MATLAB11 → 速度spd，映射颜色；可改3/5/9/14等任意值
    else:
        color_map_matlab_idx = 7
    
    # cmap_style = "viridis"     # 配色盘，可选：viridis/plasma/coolwarm/rainbow/Set3/turbo等
    # node_display_size = 3      # 节点大小，和原代码node_size保持一致
    # plot_alpha = 0.9           # 节点透明度（0~1），高密度节点建议0.6~0.9

    # ====================== 2. 数据预处理（兼容GPU张量+解耦，通用写法） ======================
    # 提取graph_pyg.x的所有特征，转为numpy数组（GPU→CPU兼容）
    if torch.cuda.is_available() and graph_pyg.x.is_cuda:
        node_feat_np = graph_pyg.x.cpu().detach().numpy()  # GPU张量转CPU再转numpy
    else:
        node_feat_np = graph_pyg.x.detach().numpy()        # CPU张量直接转numpy

    # ✅ 精准提取数据（严格对应你的MATLAB索引规则）
    x_coords = node_feat_np[:, 0]   # MATLAB1 → Python0：节点X坐标
    y_coords = node_feat_np[:, 1]   # MATLAB2 → Python1：节点Y坐标
    # 特征索引转换：MATLAB(1开始) → Python(0开始)，自动计算无需手动改
    color_feat_vals = node_feat_np[:, color_map_matlab_idx - 1]  

    # ====================== 3. 特征-颜色映射 核心绘图（scatter散点图） ======================
    plt.figure(figsize=(16, 10), dpi=100)  # 画布尺寸+分辨率优化，适配路网可视化
    scatter = plt.scatter(
        x=x_coords,
        y=y_coords,
        s=node_display_size,       # 节点大小，和原代码一致
        c=color_feat_vals,         # ✅ 核心：特征值映射颜色
        cmap=cmap_style,           # ✅ 配色盘选择
        alpha=plot_alpha,          # 透明度，解决节点重叠遮挡问题
        edgecolors="none",          # 关闭节点边框，提升可视化质感
    )

    # ====================== 4. 关键美化+辅助配置（必加，可视化更专业） ======================
    # 添加颜色条（联动特征值与颜色，必备！）
    cbar = plt.colorbar(scatter, shrink=0.8)
    # 自动生成颜色条标题（显示当前映射的特征名称）
    feat_name_dict = {1: "X Position", 2: "Y Position",
        3: "Node Type", 4: "Free Ends", 5: "Lane Number",
        6: "Road Type", 7: "Speed Limit", 8: "Drivable Area",
        9: "Vehicle Occupancy", 10: "Vehicle Type", 11: "Vehicle Speed",
        12: "Vehicle Acc", 13: "Vehicle Heading", 14: "Ego Occupancy", 15: "Route Index"
    }

    cbar.set_label(feat_name_dict.get(color_map_matlab_idx, f"feature-MATLAB index{color_map_matlab_idx}"), fontsize=12)

    # 图形标题（自动显示当前可视化的特征）
    plt.title(f"Node Scatter Visualization | Color mapped to: {feat_name_dict.get(color_map_matlab_idx, 'Custom Feature')}", 
            fontsize=14, pad=20)

    # 关闭坐标轴（路网可视化无需坐标刻度，更简洁）
    plt.axis('off')
    # 让横纵坐标轴尺度一致，避免 distortion
    plt.axis('equal')
    # 紧凑布局，避免颜色条/标题溢出
    plt.tight_layout()

    # 显示图形
    plt.show()