# 地图类型转换说明

##  OpenStreetMap地图转换SUMO地图

打开终端，修改输入输出文件名称，执行
``` bash
netconvert --osm-files Yizhuang.osm -o berlin.net.xml --remove-edges.by-type highway.footway,railway.subway,highway.pedestrain,railway.tram,highway.service,highway.cycleway,highway.raceway,highway.path,highway.steps --remove-edges.isolated --geometry.remove --ramps.guess --junctions.join true --junctions.join-dist 50 --tls.guess-signals --tls.discard-simple --tls.join --tls.default-type actuated
```

[详细内容见官方帮助文档](https://sumo.dlr.de/docs/Networks/Import/OpenStreetMap.html)
以及
[知乎教程](https://zhuanlan.zhihu.com/p/670176581)
[CSDN博客](https://blog.csdn.net/renguoqing1001/article/details/78657981)


关于地形几何文件的转入：
``` bash
polyconvert --net-file maps/lianyg_yanc.net.xml --osm-files maps/Lianyungang_yancheng.osm/LianYG_YanC.osm -o LianYG_YanC.poly.xml
```
↑，以及车流随机设置、自定义车流每个参数的意义，详见：[CSDN博客2地形转换](https://blog.csdn.net/qq_51348866/article/details/134081658)

修改输入输出文件名称，执行
``` bash
netconvert --osm-files MyYizhuang.osm -o my_yizhuang.net.xml --remove-edges.by-type highway.footway,railway.subway,highway.pedestrain,railway.tram,highway.service,highway.cycleway,highway.raceway,highway.path,highway.steps --remove-edges.isolated --geometry.remove --ramps.guess --junctions.join true --junctions.join-dist 50 --tls.guess-signals --tls.discard-simple --tls.join --tls.default-type actuated
```


##  SUMO地图转换OpenDRIVE地图
``` bash
netconvert --sumo-net-file lianyg_yanc.net.xml --opendrive-output lianyg_yanc.xodr
```
输出结果：
``` bash
Warning: Found angle of 175.33 degrees at edge '-427319962#3', segment 0.
Warning: Found sharp turn with radius 4.40 at the start of edge '-427319962#3'.
Warning: Shape for junction '478786159-AddedOffRampNode' has distance 34.00 to its given position.
Warning: Shape for junction '8261066118' has distance 26.86 to its given position.
Warning: Speed of straight connection '218674194_0->189277063#2-AddedOnRampEdge_0' reduced by 13.58 due to turning radius of 13.58 (length=3.86, angle=32.32).
Warning: Speed of straight connection '190507161#2_0->416902910#1_0' reduced by 6.45 due to turning radius of 37.62 (length=16.21, angle=40.22).
Warning: Speed of straight connection '427319962#3_0->-427319962#3_0' reduced by 10.65 due to turning radius of 1.91 (length=3.20, angle=180.00).
Success.
```
转换成功。