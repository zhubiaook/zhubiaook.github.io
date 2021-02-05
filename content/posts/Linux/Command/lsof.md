---
title: "lsof"
date: 2021-02-03
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "lsof"
    identifier: "Linux.Command.lsof.md"
    parent: Linux.Command
---

## 命令格式

> `lsof [options] [name]` 

* options: 选项

* name: 文件

注意点：

* 通常多个选项直接是 or 关系，即同时显示多个选项匹配到的内容，要使用 and 关系，添加选项 `-a` 

* `-r TIME` 不断执行lsof命令，间隔时间为TIME

* `-n`: 不进行域名解析

* `-P`: 显示端口为数字，不是端口名

## 显示网络信息

> `-i [46][protocol][@hostname|hostaddr][:service|port]` 

- 46
  
  - 4: IPv4
  
  - 6: IPv6

- protocol: TCP|UDP

- hostname|hostaddr: 主机名或地址

- :service|port: 端口或者/etc/services中定义的，比如http, ftp

示例1： 列出所有TCP/UDP连接

```bash
lsof -i
```

示例2： 列出本地socket连接

```bash
lsof -U
```

示例3：显示IPv4 TCP连接

```bash
lsof -i 4TCP
```

示例4： 显示IPv4 TCP 22号端口连接

```bash
lsof -i 4TCP:22
```

示例5： 显示IPv4 TCP 地址：0.0.0.0 端口：22的连接

```bash
lsof -i 4TCP@0.0.0.0:22
```

> `-s [protocol:state]` 

- protocol: TCP|UDP

- state:
  
  - CLOSED
  
  - IDLE
  
  - BOUND
  
  - LISTEN
  
  - ESTABLISHED
  
  - SYN_SENT
  
  - SYN_RCDV
  
  - CLOSE_WAIT
  
  - FIN_WAITE1
  
  - CLOSING
  
  - LAST_ACK
  
  - FIN_WAIT_2
  
  - TIME_WAIT
  
  - Unbound
  
  - Idle

示例1： 显示IPv4 TCP 22号端口 状态为监听的连接

```bash
lsof -i 4TCP:22 -s TCP:LISTEN
```

## 进程打开的文件

> `lsof -p PID|^PID` 

示例1： 进程PID：323打开的文件描述符

```bash
lsof -p 323
```

> `lsof -c EXECUTEFILE`

示例1： 可执行文件bash启动的进程所打开的文件

```bash
lsof -c bash
```

## 文件被哪些进程打开

> `lsof [+d|+D] FILE

* +d 当前目录下面被打开的文件

* +D 递归当前目录下被打开的文件

* FILE: 文件，目录

示例1： test.txt被哪些进程打开

```bash
lsof test.txt
```

示例2：`/opt/c/` 目录及子目录被下的所有文件被哪些进程打开

```bash
lsof +D /opt/c/
```

> `-d FD|FD1-FD2|FD1,FD2,...|^FD1 |txt|mem`

文件描述符被哪些进程使用

示例1： 0-2文件描述符被哪些进程使用

```bash
lsof -d 0-2
```

示例2： 显示程序文件

```bash
lsof -d txt
```
