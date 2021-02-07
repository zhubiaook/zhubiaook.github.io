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

常规选项：

* -i INTERFACE： 指定网络设备

* -n 不进行域名解析，显示IP

* -nn 显示IP和端口

* -c N 抓包数量

* -P in|out|inout 指定抓的是流入还是流出包

输出选项：

* -e 显示源，目的MAC地址

* -q 输出精简信息

* -X, -XX 输出包的头部数据

* -v, -vv, -vv 产生详细输出

其他选项：

* -D 列出抓包接口，可用于`-i` 选项

* -F  从文件中读取过滤条件

* -w FILE.cap 将抓包数据输出到文件，而不是标准输出

* -r 从文件中读取数据

> 过滤条件

* 过滤主机：`[src|dst] host IP` 

* 过滤端口：`[src|dst] port PORT`

* 网络过滤：`[src|dst] net NET_ADDRESS`

* 协议过滤：`arp|ip|tcp|udp|icmp`

> 逻辑表达式

* !, not

* &&, and

* ||, or

> tcpdump中对TCP头部控制字段的表示

| CWR | ECE | URG | ACK | PSH | RST | SYN | FIN |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| W   | E   | U   | .   | P   | R   | S   | F   |



## 案例

抓取所有经过eth1，目的地址是192.168.1.254或192.168.1.200端口是80的TCP数据

```bash
tcpdump -i eth1 '((tcp) and (port 80) and ((dst host 192.168.1.254) or (dst host 192.168.1.200)))'
```

## 参考

[tcpdump - Linux Wiki](https://linuxwiki.github.io/NetTools/tcpdump.html)
