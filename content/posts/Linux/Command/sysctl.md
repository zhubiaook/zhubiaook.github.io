---
title: "sysctl"
date: 2020-09-01
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "sysctl"
    identifier: "Linux.Command.sysctl.md"
    parent: Linux.Command
---

> sysctl 用来修改内核参数(`/proc/sys/`)

## 语法

```bash
sysctl [OPTIONS] [variable[=value]]
sysctl -p [FILE]
```

## 选项

```bash
-a, -A: 显示所有变量及值
-n: 只显示值
-w: 设置变量的值(临时)
-p: 从指定的文件读取变量和值修改内核参数(永久)，默认从/etc/sysctl.conf读取
```

## 示例：

查看所有内核参数

```bash
sysctl -a
```

输出：

```
net.core.rmem_default = 212992
net.core.rmem_max = 212992
net.core.rps_sock_flow_entries = 0
net.core.somaxconn = 128
net.core.warnings = 1
net.core.wmem_default = 212992
net.core.wmem_max = 212992
net.core.xfrm_acq_expires = 30
net.core.xfrm_aevent_etime = 10
net.core.xfrm_aevent_rseqth = 2
net.core.xfrm_larval_drop = 1
net.ipv4.cipso_cache_bucket_size = 10
net.ipv4.cipso_cache_enable = 1
net.ipv4.cipso_rbm_optfmt = 0
net.ipv4.cipso_rbm_strictvalid = 1
net.ipv4.conf.all.accept_local = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.arp_accept = 0
...
```

查看指定内核变量

```bash
sysctl net.ipv4.ip_forward
```

输出

```bash
net.ipv4.ip_forward = 1
```

临时修改指定内核变量的值

```bash
sysctl -w net.ipv4.ip_forward=0
```

永久修改，需要将变量写入`/etc/sysct.conf` 文件中

```bash
$ cat /etc/sysct.conf
net.ipv4.ip_forward = 1
```

然后加载文件，使配置生效

```bash
sysctl -p
```
