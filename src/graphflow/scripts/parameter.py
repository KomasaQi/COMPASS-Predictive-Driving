# -*- coding: utf-8 -*-
"""
@Author: Komasa Qi
@Contact: komasaqi@foxmail.com
"""
import argparse
from texttable import Texttable




def parse_args():
    parser = argparse.ArgumentParser()  # 参数解析器对象

    # 训练设置
    parser.add_argument('--exp_name', type=str, default='Exp_ploynomer_all_ActEmb', help='Name of the experiment')
    parser.add_argument('--seed', type=int, default=16, help='Random seed of the experiment')
    parser.add_argument('--train_batch_size', type=int, default=2, help='Size of the training batch')
    parser.add_argument('--test_batch_size', type=int, default=1, help='Size of the testing batch')
    parser.add_argument('--gpu_index', type=int, default=0, help='Index of GPU(set <0 to use CPU)')
    parser.add_argument('--epochs', type=int, default=20, help='Maximum number of epochs')
    parser.add_argument('--pred_steps', type=int, default=20, help='Prediction steps, default 20s')
    parser.add_argument('--time_length', type=int, default=21, help='Time length of the input sequence')
    parser.add_argument('--lr', type=float, default=0.0002, help='Learning rate of AdamW')
    parser.add_argument('--risk_loss_weight', type=float, default=1.0, help='Weight of risk field loss')
    parser.add_argument('--ego_loss_weight', type=float, default=0.5, help='Weight of ego occupancy loss')
    parser.add_argument('--occ_loss_weight', type=float, default=0.5, help='Weight of other vehicles occupancy loss')
    parser.add_argument('--spd_loss_weight', type=float, default=0.1, help='Weight of speed loss')          # 非0~1
    parser.add_argument('--acc_loss_weight', type=float, default=0.1, help='Weight of acceleration loss')   # 非0~1
    parser.add_argument('--head_loss_weight', type=float, default=0.1, help='Weight of heading loss')       # 非0~1
    parser.add_argument('--vtype_loss_weight', type=float, default=0.02, help='Weight of vehicle type loss') # one-hot-15分类
    parser.add_argument('--route_loss_weight', type=float, default=0.02, help='Weight of route loss')        # one-hot-4分类
    parser.add_argument('--lr_decay', type=float, default=0.999, help='Learning rate decay')
    
    # 数据超参数
    parser.add_argument('--vehicle_thred', type=float, default=0.01, help='Threshold of vehicle occupancy valid definition')
    parser.add_argument('--dyn_feature_dim', type=int, default=25, help='Dimension of dynamic features')
    parser.add_argument('--static_feature_dim', type=int, default=6, help='Dimension of static features')
    parser.add_argument('--action_dim', type=int, default=2, help='Dimension of action features')
    parser.add_argument('--action_emb_dim', type=int, default=4, help='Dimension of action embeddings')
    
    # 模型超参数
    parser.add_argument('--time_emb_dim', type=int, default=128, help='Time embedding dimension')
    parser.add_argument('--base_ch', type=int, default=64, help='Base channel number')
    parser.add_argument('--output_dim', type=int, default=25, help='Number of output node features')
    parser.add_argument('--num_heads', type=int, default=8, help='Number of attention heads')
    parser.add_argument('--edge_dim', type=int, default=5, help='Hidden dimensions of edge features')
    parser.add_argument('--cl_decay_steps', type=int, default=26, help='Curriculum learning decay steps, \
                                                                       if 700, then 1 → 0.5 → 0.25 → 0.125,\
                                                                     to 0 around 7000 steps, 10 times the value set')
    parser.add_argument('--use_curriculum_learning', type=bool, default=True, help='Use curriculum learning')
    parser.add_argument('--future_decay_gamma', type=float, default=0.95, help='Decay gamma of future predictions')
    
    # 调试可视化用
    parser.add_argument('--num_image_to_show', type=int, default=50, help='Number of images to show')
    
    
    parser.add_argument('--num_layers', type=int, default=1, help='Number of Graphormer layers')
    parser.add_argument('--node_dim', type=int, default=128, help='Hidden dimensions of node features') 
    parser.add_argument('--max_in_degree', type=int, default=5, help='Max in degree of nodes')
    parser.add_argument('--max_out_degree', type=int, default=5, help='max out degree of nodes')
    parser.add_argument('--max_path_distance', type=int, default=5, help='Max pairwise distance between two nodes')

    args = parser.parse_args()  # 解析命令行参数

    return args


class IOStream():
    """训练日志文件"""
    def __init__(self, path):
        self.file = open(path, 'a') # 附加模式：用于在文件末尾添加内容，如果文件不存在则创建新文件

    def cprint(self, text):
        print(text)
        self.file.write(text + '\n')
        self.file.flush() # 确保将写入的内容刷新到文件中，以防止数据在缓冲中滞留

    def close(self):
        self.file.close()


def table_printer(args):
    """绘制参数表格"""
    args = vars(args) # 转成字典类型
    keys = sorted(args.keys()) # 按照字母顺序进行排序
    table = Texttable()
    table.set_cols_dtype(['t', 't']) # 列的类型都为文本(str)
    rows = [["Parameter", "Value"]] # 设置表头
    for k in keys:
        rows.append([k.replace("_", " ").capitalize(), str(args[k])]) # 下划线替换成空格，首字母大写
    table.add_rows(rows)
    return table.draw()