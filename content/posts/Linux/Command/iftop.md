---
title: "iftop"
date: 2020-12-18
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "iftop"
    identifier: "Linux.Command.iftop.md"
    parent: Linux.Command
---



## 安装

```bash
yum -y install iftop
```



## 使用

启动

```bash
iftop
```

进入界面命令

```yaml
进入界面后的命令
------------------
h: 进入帮助命令
L: 显示流量柱状图

主机显示：
    t: TX流量 / RX流量 / 全部
    n: 显示名称 / 不解析名称
    s|d: 显示/隐藏源地址 | 显示/隐藏目的地址

端口显示：
    p: 显示所有端口
    N: 显示端口名称 / 不显示端口名称，显示数字
    s|d 显示/隐藏源端口 | 显示/隐藏目的端口

排序:
    1/2/3: 按第1/2/3列排序
    <: 按源地址名称排列
    >: 按目的地址名称排列
    o: 固定当前排列，不刷新

通用选项：
    P: 暂停刷新
    h: 帮助
```
