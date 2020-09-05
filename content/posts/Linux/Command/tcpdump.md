---
title: "tcpdump"
date: 2020-09-04
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "tcpdump"
    identifier: "Linux.Command.tcpdump.md"
    parent: Linux.Command
---



## 语法

```bash
tcpdump [OPTION] [FILTER]
```

> 选项

* -i INTERFACE： 指定网络设备

* -e 显示源，目的MAC地址

* -n 部进行域名解析



> 过滤条件

* 过滤主机：`[src|dst] host IP` 

* 过滤端口：`[src|dst] port PORT`

* 网络过滤：`[src|dst] net NET_ADDRESS`

* 协议过滤：`arp|ip|tcp|udp|icmp`



> 逻辑表达式

* !, not

* &&, and

* ||, or



## 案例

抓取所有经过eth1，目的地址是192.168.1.254或192.168.1.200端口是80的TCP数据

```bash
tcpdump -i eth1 '((tcp) and (port 80) and ((dst host 192.168.1.254) or (dst host 192.168.1.200)))'
```



## 参考

[tcpdump - Linux Wiki](https://linuxwiki.github.io/NetTools/tcpdump.html)
