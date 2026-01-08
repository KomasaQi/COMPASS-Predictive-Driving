# -*- coding: utf-8 -*-
"""
@Author: Komasa Qi
@Contact: komasaqi@foxmail.com
"""
import os, torch, random
from tqdm import tqdm, trange
import torch.nn as nn
import torch.optim as optim
from torch.utils.tensorboard import SummaryWriter  
from data import load_compass_data
from model import Graphflower
from parameter import parse_args, IOStream, table_printer

from utils import plot_graph, FocalLoss
from torch_geometric.loader import DataLoader
from torch import serialization
import numpy as np
from data import TemporalData  # 从你的data模块导入TemporalData类
serialization.add_safe_globals([TemporalData])  # 加入安全白名单,就不会报加载的警告了



def train(args, IO, train_loader, num_node_features, num_edge_features, writer):

    # 使用GPU or CPU
    device = torch.device('cpu' if args.gpu_index < 0 else 'cuda:{}'.format(args.gpu_index))
    if args.gpu_index < 0:
        IO.cprint('Using CPU')
    else:
        IO.cprint('Using GPU: {}'.format(args.gpu_index))
        torch.cuda.manual_seed(args.seed)  # 设置PyTorch GPU随机种子

    # 加载模型及参数量统计 如果模型存在就加载，否则就创建新模型
    try:
        model = torch.load('outputs/%s/model.pth' % args.exp_name, weights_only=False).to(device)
    except:
        model = Graphflower(args, num_node_features, num_edge_features).to(device)                                                                                                                                          
    IO.cprint(str(model))
    total_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    IO.cprint('Model Parameter: {}'.format(total_params))

    # 优化器
    optimizer = optim.AdamW(model.parameters(), lr=args.lr)
    IO.cprint('Using AdamW')

    # 损失函数
    criterion = nn.MSELoss(reduction="mean")
    pos_ratio = 0.0062
    alpha = (1 - pos_ratio) / pos_ratio  # 这里约等于399，根据你的真实数据调整
    criterion_ego = FocalLoss(alpha=alpha, gamma=2)  # gamma=2～5 可调

    epochs = trange(args.epochs, leave=False, desc="Epochs") 
    # 混合精度训练（节省显存 + 加速）
    scaler = torch.amp.GradScaler()

    for epoch in epochs:
        #################
        ###   Train   ###
        #################
        model.train()  # 训练模式
        train_loss = 0.0  # 一个epoch，所有样本损失总和

        
        for i, data in tqdm(enumerate(train_loader), total=len(train_loader), desc="Train_Loader"):
            data = data.to(device)
            optimizer.zero_grad()

            # ✅ 使用 autocast 包裹前向传播
            # with torch.autocast(device_type='cuda', dtype=torch.float16):
            outputs = model(data)
            loss_risk = criterion(outputs[:,0], data.y[:,5])
            loss_ego = criterion_ego(outputs[:,1], data.y[:,4])
            loss = loss_risk * args.risk_loss_weight + loss_ego * args.ego_loss_weight
            
            writer.add_scalar('Train/Loss', loss.item(), epoch * len(train_loader) + i)
            writer.add_scalar('Train/Risk_Loss', loss_risk.item(), epoch * len(train_loader) + i)
            writer.add_scalar('Train/Ego_Loss', loss_ego.item(), epoch * len(train_loader) + i)

            # ✅ 使用 scaler.scale(loss) 进行反向传播
            scaler.scale(loss).backward()
            nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            scaler.step(optimizer)
            scaler.update()

            if i % 2 == 0:
                IO.cprint(' Epoch #{:03d}, Batch #{:03d}, Train_Loss: {:.6f}, Risk_Loss: {:.6f}, Ego_Loss: {:.6f}'.format(epoch, i, loss.item(), loss_risk.item(), loss_ego.item()))

            torch.cuda.empty_cache()
            
            
            train_loss += loss.item()
            # ✅ 清理中间变量
            del outputs, loss_risk, loss_ego, loss, data


        IO.cprint('Epoch #{:03d}, Train_Loss: {:.6f}'.format(epoch, train_loss / len(train_loader.dataset)))

    torch.save(model, 'outputs/%s/model.pth' % args.exp_name)
    IO.cprint('The current best model is saved in: {}'.format('******** outputs/%s/model.pth *********' % args.exp_name))


def test(args, IO, test_loader, writer):
    """测试模型"""
    # device = torch.device('cpu' if args.gpu_index < 0 else 'cuda:{}'.format(args.gpu_index))
    device = 'cpu' # 测试的时候放置爆显存
    # 输出内容保存在之前的训练日志里
    IO.cprint('')
    IO.cprint('********** TEST START **********')
    IO.cprint('Reload Best Model')
    IO.cprint('The current best model is saved in: {}'.format('******** outputs/%s/model.pth *********' % args.exp_name))

    model = torch.load('outputs/%s/model.pth' % args.exp_name, weights_only=False).to(device)
    model = model.eval()  # 创建一个新的评估模式的模型对象，不覆盖原模型

    ################
    ###   Test   ###
    ################
    test_loss = 0.0
 
    # 损失函数
    criterion = nn.MSELoss(reduction="mean") # 其他还有nn.L1Loss()、nn.SmoothL1Loss()、nn.BCELoss()、nn.BCEWithLogitsLoss()、nn.CrossEntropyLoss()等
    pos_ratio = 0.0062
    alpha = (1 - pos_ratio) / pos_ratio  # 这里约等于399，根据你的真实数据调整
    criterion_ego = FocalLoss(alpha=alpha, gamma=2)  # gamma=2～5 可调

    image_counter = 0
    for i, data in tqdm(enumerate(test_loader), total=len(test_loader), desc="Test_Loader"):
        data = data.to(device)
        # ✅ 使用 autocast 包裹前向传播
        # with torch.autocast(device_type='cuda', dtype=torch.float16):
        outputs = model(data)
        loss_risk = criterion(outputs[:,0], data.y[:,5])
        loss_ego = criterion_ego(outputs[:,1], data.y[:,4])
        loss = loss_risk + loss_ego * args.ego_loss_weight

        torch.cuda.empty_cache()
        
        
        test_loss += loss.item()

        writer.add_scalar('Test/Loss', loss.item(),  i)
        writer.add_scalar('Test/Risk_Loss', loss_risk.item(),  i)
        writer.add_scalar('Test/Ego_Loss', loss_ego.item(),  i)



        if image_counter < 55:
            image_counter += 1
            new_batch_graph = data.clone().detach()
            new_batch_graph.x = torch.cat([data.x[:,:2],outputs], dim=1)
            residual_graph = data.clone().detach()
            residual_graph.x = torch.cat([data.x[:,:2],outputs-torch.cat([data.y[:,5].unsqueeze(-1),data.y[:,4].unsqueeze(-1)],dim=1)], dim=1)
            d = new_batch_graph.to_data_list()
            d_r = residual_graph.to_data_list()
            plot_graph(d[0],feature='risk',graph_type='processed',cmap='jet')
            plot_graph(d[0],feature='ego',graph_type='processed',cmap='jet')
            plot_graph(d_r[0],feature='risk',graph_type='processed',cmap='jet')
            plot_graph(d_r[0],feature='ego',graph_type='processed',cmap='jet')
            
        # ✅ 清理中间变量
        del outputs, loss_risk, loss_ego, loss, data, new_batch_graph, d
        
    IO.cprint('TEST :: Test_Loss: {:.6f}'.format(test_loss / len(test_loader.dataset)))


def exp_init():
    """实验初始化"""
    if not os.path.exists('outputs'):
        os.mkdir('outputs')
    if not os.path.exists('outputs/' + args.exp_name):
        os.mkdir('outputs/' + args.exp_name)

    
    # 跟踪执行脚本，windows下使用copy命令，且使用双引号
    os.system(f"copy src\\graphflow\\scripts\\main.py outputs\\{args.exp_name}\\main.py.backup")
    os.system(f"copy src\\graphflow\\scripts\\data.py outputs\\{args.exp_name}\\data.py.backup")
    os.system(f"copy src\\graphflow\\scripts\\parameter.py outputs\\{args.exp_name}\\parameter.py.backup")
    os.system(f"copy src\\graphflow\\scripts\\model.py outputs\\{args.exp_name}\\model.py.backup")
    os.system(f"copy src\\graphflow\\scripts\\utils.py outputs\\{args.exp_name}\\utils.py.backup")
    os.system(f"copy src\\graphflow\\scripts\\layers.py outputs\\{args.exp_name}\\layers.py.backup")


# ====================== ✅ 主程序调用======================
if __name__ == '__main__':
    args = parse_args()
    random.seed(args.seed)  # 设置Python随机种子
    torch.manual_seed(args.seed)  # 设置PyTorch随机种子
    exp_init()

    IO = IOStream('outputs/' + args.exp_name + '/run.log')
    IO.cprint(str(table_printer(args)))  # 参数可视化
    writer = SummaryWriter(log_dir='E:/runs/{}'.format(args.exp_name))

    train_loader, test_loader, num_node_features, num_edge_features = load_compass_data(args)

    train(args, IO, train_loader, num_node_features, num_edge_features,writer)
    
    test(args, IO, test_loader,writer)
    
    writer.close()

