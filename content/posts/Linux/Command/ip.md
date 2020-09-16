---
title: "ip"
date: 2020-09-02
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "ip"
    identifier: "Linux.Command.ip.md"
    parent: Linux.Command
---

## 语法

```bash
ip [OPTIONS] OBJECT {COMMAND | help}
```

> OBJECT

* link, l: 网络设备

* address, a:  网络协议（IP, IPv6）地址

* route, r: 路由表

* netns: net-namespace管理

* addrlabel, addrl: Label configuration for protocol address selection

* neighbour, n: ARP or NDISC cache entry.

* rule, ru: Rule in routing policy database

* tunnel, t: Tunnel over IP

> 帮助

* ip help

* ip OBJECT help

* ip OBJECT COMMAND help

## 示例

### ip link

**创建网络设备**

```bash
ip link add [name] DEVICE type TYPE
```

> TYPE

* vlan

* veth: 虚拟网卡，成对出现，一端连接协议栈，另外一端和另外一个相连

* bridge：虚拟网桥

* vxlan

创建虚拟网卡`veth` 

```bash
ip link add name veth0 type veth peer name veth1
```

创建虚拟网桥`bridge`

```bash
ip link add name br0 type bridge
```

`veth0` 设备加入网桥`br0`

```bash
ip link set veth0 master br0
```

修改设备的`net-namespace`

```bash
ip link set veth0 netns net1
```

**启动/停止网络设备**

```bash
ip link set dev DEVICE up|down
```

**修改*txqueuelen*大小**

```bash
ip link set txqueuelen 1000 dev eth0
```

**修改MTU大小**

```bash
ip link set mtu 9000 dev eth0
```

### ip address

**查看网卡信息**

```bash
ip a show
```

**Assigns the IP address to the interface**

```bash
ip a add IP/mask dev INTERFACE
```

```bash
ip a add 192.168.0.32/24 dev eth0
```

### ip route

**查看路由表**

```bash
ip route 
```

**增加网关地址**

```bash
ip route add default via 192.168.0.1
```

**增加路由条目**

```bash
ip route add 172.19.0.0/24 dev eth0
```

或使用下一跳地址

```bash
ip route add 172.19.0.0/24 via 172.19.0.200
```

### ip netns

创建新的`net-namespace`

```bash
ip netns add net01
```

进入新的网络命令空间`net01`并执行`bash`程序

```bash
ip netns exec net1 /bin/bash
```

可以验证已进入新的net-namespace, 查看net的node节点和老的namespace的不一样。

```bash
readlink /proc/$$/ns/net
```

### ip neigh

** 查看ARP缓存**

```bash
ip n show
```

** 增加ARP缓存**

```bash
ip n add IP lladdr MAC dev DEVICE nud STATE
```

```bash
ip neigh add 192.168.1.5 lladdr 00:1a:30:38:a8:00 dev eth0 nud perm
```

## `net-tools` 与 `iproute` 包命令对比

| Old command (Deprecated)                                    | New command                                             |
| ----------------------------------------------------------- | ------------------------------------------------------- |
| ifconfig -a                                                 | ip a                                                    |
| ifconfig enp6s0 down                                        | ip link set enp6s0 down                                 |
| ifconfig enp6s0 up                                          | ip link set enp6s0 up                                   |
| ifconfig enp6s0 192.168.2.24                                | ip addr add 192.168.2.24/24 dev enp6s0                  |
| ifconfig enp6s0 netmask 255.255.255.0                       | ip addr add 192.168.1.1/24 dev enp6s0                   |
| ifconfig enp6s0 mtu 9000                                    | ip link set enp6s0 mtu 9000                             |
| ifconfig enp6s0:0 192.168.2.25                              | ip addr add 192.168.2.25/24 dev enp6s0                  |
| netstat                                                     | ss                                                      |
| netstat -tulpn                                              | ss -tulpn                                               |
| netstat -neopa                                              | ss -neopa                                               |
| netstat -g                                                  | ip maddr                                                |
| route                                                       | ip r                                                    |
| route add -net 192.168.2.0 netmask 255.255.255.0 dev enp6s0 | ip route add 192.168.2.0/24 dev enp6s0                  |
| route add default gw 192.168.2.254                          | ip route add default via 192.168.2.254                  |
| arp -a                                                      | ip neigh                                                |
| arp -v                                                      | ip -s neigh                                             |
| arp -s 192.168.2.33 1:2:3:4:5:6                             | ip neigh add 192.168.3.33 lladdr 1:2:3:4:5:6 dev enp6s0 |
| arp -i enp6s0 -d 192.168.2.254                              | ip neigh del 192.168.2.254 dev wlp7s0                   |

## 参考文档

[Linux ip Command Examples - nixCraft](https://www.cyberciti.biz/faq/linux-ip-command-examples-usage-syntax/#2)
