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

from utils import plot_graph, FocalLoss, compute_sampling_threshold
from torch_geometric.loader import DataLoader
from torch import serialization
import numpy as np
from data import TemporalData  # 从你的data模块导入TemporalData类
serialization.add_safe_globals([TemporalData])  # 加入安全白名单,就不会报加载的警告了
# 导入step调度器
from torch.optim.lr_scheduler import LambdaLR



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
    
    # 调度器
    scheduler = LambdaLR(optimizer, lr_lambda=lambda epoch: args.lr_decay ** epoch)

    # 损失函数
    criterion_risk = nn.MSELoss(reduction="mean")
    criterion_spd = nn.MSELoss(reduction="mean")
    criterion_acc = nn.MSELoss(reduction="mean")
    criterion_head = nn.MSELoss(reduction="mean")
    criterion_occ = nn.MSELoss(reduction="mean")
    criterion_vtypes = nn.CrossEntropyLoss(reduction="mean")
    criterion_routes = nn.CrossEntropyLoss(reduction="mean")
    
    pos_ratio = 0.0062
    alpha = (1 - pos_ratio) / pos_ratio  # 这里约等于399，根据你的真实数据调整
    criterion_ego = FocalLoss(alpha=alpha, gamma=2)  # gamma=2～5 可调



    epochs = trange(args.epochs, leave=False, desc="Epochs") 
    # 混合精度训练（节省显存 + 加速）
    scaler = torch.amp.GradScaler()

    ep_counter = 0
    for epoch in epochs:
        #################
        ###   Train   ###
        #################
        model.train()  # 训练模式
        train_loss = 0.0  # 一个epoch，所有样本损失总和

        
        for i, data_raw in tqdm(enumerate(train_loader), total=len(train_loader), desc="Train_Loader"):
            data = data_raw.to(device)
            static_feature = data.x[:,:8].clone().detach() # 静态节点信息，不随时间变化
            y_labels = data.y.clone().detach()
            edge_index = data.edge_index.clone().detach()
            edge_attr = data.edge_attr.clone().detach()
            actions_lc = data.action_lc.clone().detach()
            actions_acc = data.action_acc.clone().detach()
            index_stat = np.arange(args.time_length)
            
            for j in range(args.pred_steps):
            # for j in range(2):
                data.y = y_labels[:,:,j].clone().detach()
                data.timestamp = torch.FloatTensor([j]).to(device)
                data.action_acc = actions_acc[:, index_stat + j].clone().detach()
                data.action_lc = actions_lc[:, index_stat + j].clone().detach()
                
                optimizer.zero_grad()
                
                # 转换后的动态特征y维度(25维) = {
                    #     'occ': 0, 'spd': 1, 'acc': 2,
                    #     'head': 3, 'ego': 4, 'risk': 5, 'vtype': 6-20(one-hot,15分类), 'route': 21-24(one-hot,4分类)
                risk, ego, occ, spd, acc, head, vtypes, routes = model(data)
                
                # 车辆mask，找到所有道路车辆的索引，也就是y_occ + y_ego > args.vehicle_thred的索引
                vehicle_mask = (data.y[:,0] + data.y[:,4] > args.vehicle_thred)
                loss_occ = criterion_occ(occ, data.y[:,0])  # 要刻画边缘
                loss_spd = criterion_spd(spd[vehicle_mask], data.y[vehicle_mask,1])  # 只计算车辆的速度损失
                loss_acc = criterion_acc(acc[vehicle_mask], data.y[vehicle_mask,2])  # 只计算车辆的加速度损失
                loss_head = criterion_head(head[vehicle_mask], data.y[vehicle_mask,3])  # 只计算车辆的航向损失
                loss_ego = criterion_ego(ego, data.y[:,4])  
                loss_risk = criterion_risk(risk, data.y[:,5])
                loss_vtypes = criterion_vtypes(vtypes[vehicle_mask], data.y[vehicle_mask,6:21].argmax(dim=1)) # 只计算车辆的类型损失
                loss_routes = criterion_routes(routes[vehicle_mask], data.y[vehicle_mask,21:25].argmax(dim=1)) # 只计算车辆的路线损失
                loss = loss_risk * args.risk_loss_weight \
                    + loss_ego * args.ego_loss_weight \
                    + loss_occ * args.occ_loss_weight \
                    + loss_spd * args.spd_loss_weight \
                    + loss_acc * args.acc_loss_weight \
                    + loss_head * args.head_loss_weight \
                    + loss_vtypes * args.vtype_loss_weight \
                    + loss_routes * args.route_loss_weight
                decaying_factor = args.future_decay_gamma ** j # 对未来时间步的损失进行衰减
                loss *= decaying_factor
                      
                writer.add_scalar('Train/Loss', loss.item(), ep_counter * len(train_loader) + i*args.pred_steps + j)
                writer.add_scalar('Train/Risk_Loss', loss_risk.item(), ep_counter * len(train_loader) + i*args.pred_steps + j)
                writer.add_scalar('Train/Ego_Loss', loss_ego.item(), ep_counter * len(train_loader) + i*args.pred_steps + j)
                writer.add_scalar('Train/Occ_Loss', loss_occ.item(), ep_counter * len(train_loader) + i*args.pred_steps + j)
                writer.add_scalar('Train/Spd_Loss', loss_spd.item(), ep_counter * len(train_loader) + i*args.pred_steps + j)
                writer.add_scalar('Train/Acc_Loss', loss_acc.item(), ep_counter * len(train_loader) + i*args.pred_steps + j)
                writer.add_scalar('Train/Head_Loss', loss_head.item(), ep_counter * len(train_loader) + i*args.pred_steps + j)
                writer.add_scalar('Train/Vtypes_Loss', loss_vtypes.item(), ep_counter * len(train_loader) + i*args.pred_steps + j)
                writer.add_scalar('Train/Routes_Loss', loss_routes.item(), ep_counter * len(train_loader) + i*args.pred_steps + j)

                # ✅ 使用 scaler.scale(loss) 进行反向传播
                scaler.scale(loss).backward()
                nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
                scaler.step(optimizer)
                scaler.update()
                
                
                pred_road_mask = (occ + ego < args.vehicle_thred)
                spd[pred_road_mask] = 0.0  # 道路上的速度设为0
                acc[pred_road_mask] = 0.0  # 道路上的加速度设为0
                head[pred_road_mask] = 0.0  # 道路上的航向设为0
                vtypes[pred_road_mask] = 0.0  # 道路上的类型设为0
                routes[pred_road_mask] = 0.0  # 道路上的路线设为0
                
                new_x = torch.cat([occ.detach().unsqueeze(-1), spd.detach().unsqueeze(-1), 
                                    acc.detach().unsqueeze(-1), head.detach().unsqueeze(-1), 
                                    ego.detach().unsqueeze(-1), risk.detach().unsqueeze(-1),
                                    vtypes.detach(), routes.detach()],dim=1) # [N*B, 25]
                
                old_x = data.x.detach()[:,33:]
                real_x = data.y.detach()
                
                # 课程学习（仅训练时启用）：以一定概率使用真实标签作为下一个输入
                threshold = 1
                if args.use_curriculum_learning:
                    # 生成0-1之间的随机数c
                    c = np.random.uniform(0, 1)
                    # 计算当前采样阈值ε_i
                    threshold = compute_sampling_threshold(args, i)
                    # 若c < ε_i：使用真实标签作为下一个输入（加速训练初期收敛）
                    # 若c ≥ ε_i：使用当前预测结果作为下一个输入（提升模型鲁棒性）
                    if c < threshold:
                        new_x = real_x
                    
                data.x = torch.cat([static_feature, old_x, new_x],dim=1)
                data.edge_index = edge_index.detach()
                data.edge_attr = edge_attr.detach()
                data.batch = data.batch.detach()
                data.action_acc = data.action_acc.detach()
                data.action_lc = data.action_lc.detach()
                data.ptr = data.ptr.detach()

                train_loss += loss.item()
                
                IO.cprint(' Epoch #{:03d}, Batch #{:03d}, Step #{:03d}, Train_Loss: {:.4f}, lr: {:.6f}'.format(epoch+1, i+1, j+1, loss.item(), optimizer.param_groups[0]['lr']))
                IO.cprint('                Risk_Loss: {:.4f}, Ego_Loss: {:.4f}, Curriculum_Progress: {:.4f} %'.format(loss_risk.item(), loss_ego.item(), (1 - threshold) * 100))
                IO.cprint('                Occ_Loss: {:.4f}, Spd_Loss: {:.4f}, Acc_Loss: {:.4f}, Head_Loss: {:.4f}, Vtypes_Loss: {:.4f}, Routes_Loss: {:.4f}'.format(loss_occ.item(), loss_spd.item(), loss_acc.item(), loss_head.item(), loss_vtypes.item(), loss_routes.item()))
                
                
                # ✅ 清理中间变量
                del occ, risk, spd, ego, acc, head, vtypes, routes, new_x, old_x, real_x
                del loss, loss_risk, loss_ego, loss_occ, loss_spd, loss_acc, loss_head, loss_vtypes, loss_routes
                torch.cuda.empty_cache()
            
            scheduler.step() # 更新学习率
            del data, y_labels, static_feature
            torch.cuda.empty_cache()

        
        ep_counter += 1 # 每个epoch结束后，计数器+1
        IO.cprint('Epoch #{:03d}, Train_Loss: {:.6f}'.format(epoch, train_loss / len(train_loader.dataset)))
        torch.save(model, 'outputs/%s/model_epoch_%03d.pth' % (args.exp_name, epoch))

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
    criterion_risk = nn.MSELoss(reduction="mean") # 其他还有nn.L1Loss()、nn.SmoothL1Loss()、nn.BCELoss()、nn.BCEWithLogitsLoss()、nn.CrossEntropyLoss()等
    pos_ratio = 0.0062
    alpha = (1 - pos_ratio) / pos_ratio  # 这里约等于399，根据你的真实数据调整
    criterion_ego = FocalLoss(alpha=alpha, gamma=2)  # gamma=2～5 可调
    criterion_occ = nn.BCEWithLogitsLoss(pos_weight=torch.tensor(alpha))
    criterion_spd = nn.MSELoss(reduction="mean")
    criterion_acc = nn.MSELoss(reduction="mean")
    criterion_head = nn.MSELoss(reduction="mean")
    criterion_vtypes = nn.CrossEntropyLoss()
    criterion_routes = nn.CrossEntropyLoss()

    image_counter = 0
    for i, data_raw in tqdm(enumerate(test_loader), total=len(test_loader), desc="Test_Loader"):
        data = data_raw.to(device)
        static_feature = data.x[:,:8].clone().detach() # 静态节点信息，不随时间变化
        y_labels = data.y.clone().detach()
        edge_index = data.edge_index.clone().detach()
        edge_attr = data.edge_attr.clone().detach()
        actions_lc = data.action_lc.clone().detach()
        actions_acc = data.action_acc.clone().detach()
        index_stat = np.arange(args.time_length) 
        
        for j in range(args.pred_steps):
            data.y = y_labels[:,:,j].clone().detach()
            data.timestamp = torch.FloatTensor([j]).to(device)
            data.action_acc = actions_acc[:, index_stat + j].clone().detach()
            data.action_lc = actions_lc[:, index_stat + j].clone().detach()
                
            risk, ego, occ, spd, acc, head, vtypes, routes = model(data)
            outputs = torch.cat([occ.unsqueeze(-1), vtypes.argmax(dim=1).unsqueeze(-1), spd.unsqueeze(-1)*20 + 20, acc.unsqueeze(-1), head.unsqueeze(-1), 
                                ego.unsqueeze(-1), routes.argmax(dim=1).unsqueeze(-1), risk.unsqueeze(-1) ],dim=1)
            
            
            # 车辆mask，找到所有道路车辆的索引，也就是y_occ + y_ego > args.vehicle_thred的索引
            vehicle_mask = (data.y[:,0] + data.y[:,4] > args.vehicle_thred)
            loss_occ = criterion_occ(occ, data.y[:,0])  # 要刻画边缘
            loss_spd = criterion_spd(spd[vehicle_mask], data.y[vehicle_mask,1])  # 只计算车辆的速度损失
            loss_acc = criterion_acc(acc[vehicle_mask], data.y[vehicle_mask,2])  # 只计算车辆的加速度损失
            loss_head = criterion_head(head[vehicle_mask], data.y[vehicle_mask,3])  # 只计算车辆的航向损失
            loss_ego = criterion_ego(ego, data.y[:,4])
            loss_risk = criterion_risk(risk, data.y[:,5])
            loss_vtypes = criterion_vtypes(vtypes[vehicle_mask], data.y[vehicle_mask,6:21].argmax(dim=1)) # 只计算车辆的类型损失
            loss_routes = criterion_routes(routes[vehicle_mask], data.y[vehicle_mask,21:25].argmax(dim=1)) # 只计算车辆的路线损失
            loss = loss_risk * args.risk_loss_weight \
                + loss_ego * args.ego_loss_weight \
                + loss_occ * args.occ_loss_weight \
                + loss_spd * args.spd_loss_weight \
                + loss_acc * args.acc_loss_weight \
                + loss_head * args.head_loss_weight \
                + loss_vtypes * args.vtype_loss_weight \
                + loss_routes * args.route_loss_weight
            decaying_factor = args.future_decay_gamma ** j # 对未来时间步的损失进行衰减
            loss *= decaying_factor

            writer.add_scalar('Test/Loss', loss.item(),  i)
            writer.add_scalar('Test/Risk_Loss', loss_risk.item(),  i)
            writer.add_scalar('Test/Ego_Loss', loss_ego.item(),  i)
            writer.add_scalar('Test/Occ_Loss', loss_occ.item(),  i)
            writer.add_scalar('Test/Spd_Loss', loss_spd.item(),  i)
            writer.add_scalar('Test/Acc_Loss', loss_acc.item(),  i)
            writer.add_scalar('Test/Head_Loss', loss_head.item(),  i)
            writer.add_scalar('Test/Vtypes_Loss', loss_vtypes.item(),  i)
            writer.add_scalar('Test/Routes_Loss', loss_routes.item(),  i)



            if image_counter < args.num_image_to_show:
                image_counter += 1
                new_batch_graph = data.clone().detach()
                new_batch_graph.x = torch.cat([data.x[:,:8],outputs], dim=1)
                d = new_batch_graph.to_data_list()
                plot_graph(d[0],feature='risk',graph_type='raw',cmap='jet',timestamp=j,extra_info='Pred')
                # plot_graph(d[0],feature='ego',graph_type='raw',cmap='jet',timestamp=j,extra_info='Pred')
                # plot_graph(d[0],feature='occ',graph_type='raw',cmap='jet',timestamp=j,extra_info='Pred')
                # plot_graph(d[0],feature='spd',graph_type='raw',cmap='jet',timestamp=j,extra_info='Pred')
                # plot_graph(d[0],feature='acc',graph_type='raw',cmap='jet',timestamp=j,extra_info='Pred')
                # plot_graph(d[0],feature='head',graph_type='raw',cmap='jet',timestamp=j,extra_info='Pred')
                # plot_graph(d[0],feature='vtypes',graph_type='raw',cmap='jet',timestamp=j,extra_info='Pred')
                # plot_graph(d[0],feature='routes',graph_type='raw',cmap='jet',timestamp=j,extra_info='Pred')

                y_occ = data.y[:,0].unsqueeze(-1)
                y_spd = data.y[:,1].unsqueeze(-1)*20 + 20
                y_acc = data.y[:,2].unsqueeze(-1)
                y_head = data.y[:,3].unsqueeze(-1)
                y_ego = data.y[:,4].unsqueeze(-1)
                y_risk = data.y[:,5].unsqueeze(-1)
                y_vtypes = data.y[:,6:21].argmax(dim=1).unsqueeze(-1)
                y_routes = data.y[:,21:25].argmax(dim=1).unsqueeze(-1)
                
                y_rearrange = torch.cat([y_occ, y_vtypes, y_spd, y_acc, y_head, y_ego, y_routes, y_risk], dim=1)
                residual_graph = data.clone().detach()
                residual_graph.x = torch.cat([data.x[:,:8],outputs-y_rearrange], dim=1)
                d_r = residual_graph.to_data_list()
                # plot_graph(d_r[0],feature='risk',graph_type='raw',cmap='jet',timestamp=j,extra_info='Residual')
                # plot_graph(d_r[0],feature='ego',graph_type='raw',cmap='jet',timestamp=j,extra_info='Residual')
                # plot_graph(d_r[0],feature='occ',graph_type='raw',cmap='jet',timestamp=j,extra_info='Residual')
                # plot_graph(d_r[0],feature='spd',graph_type='raw',cmap='jet',timestamp=j,extra_info='Residual')
                # plot_graph(d_r[0],feature='acc',graph_type='raw',cmap='jet',timestamp=j,extra_info='Residual')
                # plot_graph(d_r[0],feature='head',graph_type='raw',cmap='jet',timestamp=j,extra_info='Residual')
                # plot_graph(d_r[0],feature='vtypes',graph_type='raw',cmap='jet',timestamp=j,extra_info='Residual')
                # plot_graph(d_r[0],feature='routes',graph_type='raw',cmap='jet',timestamp=j,extra_info='Residual')
                
            pred_road_mask = (occ + ego < args.vehicle_thred)
            spd[pred_road_mask] = 0.0  # 道路上的速度设为0
            acc[pred_road_mask] = 0.0  # 道路上的加速度设为0
            head[pred_road_mask] = 0.0  # 道路上的航向设为0
            vtypes[pred_road_mask] = 0.0  # 道路上的类型设为0
            routes[pred_road_mask] = 0.0  # 道路上的路线设为0
            new_x = torch.cat([occ.detach().unsqueeze(-1), spd.detach().unsqueeze(-1), 
                                acc.detach().unsqueeze(-1), head.detach().unsqueeze(-1), 
                                ego.detach().unsqueeze(-1), risk.detach().unsqueeze(-1),
                                vtypes.detach(), routes.detach()],dim=1) # [N*B, 25]
            old_x = data.x.detach()[:,33:]
        
            data.x = torch.cat([static_feature, old_x, new_x],dim=1)
            data.edge_index = edge_index.detach()
            data.edge_attr = edge_attr.detach()
            data.batch = data.batch.detach()
            data.action_acc = data.action_acc.detach()
            data.action_lc = data.action_lc.detach()
            data.ptr = data.ptr.detach()
            
        
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

