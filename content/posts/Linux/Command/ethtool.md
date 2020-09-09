---
title: "ethtool"
date: 2020-09-09
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "ethtool"
    identifier: "Linux.Command.ethtool.md"
    parent: Linux.Command
---



> 查询和修改以太网卡的配置信息（网卡驱动层）
> 
> 命令显示的信息来源于网卡驱动层，即`TCP/IP`协议的链路层



## 语法

```bash
ethtool [OPTIONS] DEVNAME
```

## OPTIONS

```bash
-a 查看网卡中 接收模块RX、发送模块TX和Autonegotiate模块的状态：启动on 或 停用off。
-A 修改网卡中 接收模块RX、发送模块TX和Autonegotiate模块的状态：启动on 或 停用off。
-c display the Coalesce information of the specified ethernet card。
-C Change the Coalesce setting of the specified ethernet card。
-g Display the rx/tx ring parameter information of the specified ethernet card。
-G change the rx/tx ring setting of the specified ethernet card。
-i 显示网卡驱动的信息，如驱动的名称、版本等。
-d 显示register dump信息, 部分网卡驱动不支持该选项。
-e 显示EEPROM dump信息，部分网卡驱动不支持该选项。
-E 修改网卡EEPROM byte。
-k 显示网卡Offload参数的状态：on 或 off，包括rx-checksumming、tx-checksumming等。
-K 修改网卡Offload参数的状态。
-p 用于区别不同ethX对应网卡的物理位置，常用的方法是使网卡port上的led不断的闪；N指示了网卡闪的持续时间，以秒为单位。
-r 如果auto-negotiation模块的状态为on，则restarts auto-negotiation。
-S 显示NIC- and driver-specific 的统计参数，如网卡接收/发送的字节数、接收/发送的广播包个数等。
-t 让网卡执行自我检测，有两种模式：offline or online。
-s 修改网卡的部分配置，包括网卡速度、单工/全双工模式、mac地址等。
```



## 示例

```bash
ethtool devname

ethtool -h|--help

ethtool --version

ethtool -a|--show-pause devname

ethtool -A|--pause devname [autoneg on|off] [rx on|off] [tx on|off]

ethtool -c|--show-coalesce devname

ethtool -g|--show-ring devname

ethtool -G|--set-ring devname [rx N] [rx-mini N] [rx-jumbo N] [tx N]

ethtool -i|--driver devname

ethtool -d|--register-dump devname [raw on|off] [hex on|off] [file name]

ethtool -e|--eeprom-dump devname [raw on|off] [offset N] [length N]

ethtool -E|--change-eeprom devname [magic N] [offset N] [length N] [value N]

ethtool -k|--show-features|--show-offload devname

ethtool -K|--features|--offload devname feature on|off ...

ethtool -p|--identify devname [N]

ethtool -P|--show-permaddr devname

```
