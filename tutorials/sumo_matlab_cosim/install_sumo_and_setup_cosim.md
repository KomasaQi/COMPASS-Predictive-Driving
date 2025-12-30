# 安装SUMO并配置与Matlab的联合仿真环境

本仓库采用的是`SUMO版本1.23.1`，Matlab版本2023a。为保证相同的仿真结果，**建议安装相同版本的SUMO**(Matlab版本至少应更高，如果版本不同会出现所有编译过的mex后缀的函数需要重新编译的情况)。下面来介绍如何安装SUMO并配置与Matlab的联合仿真环境。

## 1 安装SUMO
首先下载SUMO版本1.23.1的安装包，链接为：[SUMO版本1.23.1](https://sourceforge.net/projects/sumo/files/sumo/version%201.23.1/sumo-win64extra-1.23.1.msi/download)。双击安装包，按照提示进行安装。安装完成后，记得在安装过程中有一个将`SUMO_HOME`添加到Path的选项要勾选上，这样不需要再手动操作一遍了。

## 2 配置SUMO与Matlab的联合仿真环境
联合仿真环境的配置可以参考[Matlab SUMO联合仿真环境配置](https://zhuanlan.zhihu.com/p/582181618?utm_id=0)，此处不再赘述。