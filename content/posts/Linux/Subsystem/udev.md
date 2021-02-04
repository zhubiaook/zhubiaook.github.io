---
title: "udev"
date: 2020-11-11
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "udev"
    identifier: "Linux.Subsystem.udev.md"
    parent: Linux.Subsystem
---

> 创建一个脚本，当你插入的计算机插入设备时，触发脚本的执行



## 参考文档

[技术|udev 入门：管理设备事件的 Linux 子系统](https://linux.cn/article-10329-1.html)



## udev简介

当你的计算机插入一个硬件设备，比如网卡，硬盘，U盘，鼠标，键盘，光驱等设备时，内核将给udevd一个udev事件，udevd根据`/etc/udev/rules.d/*.rules`，`/run/udev/rules.d/*.rules`, `/usr/lib/udev/rule.d/*.rules`中定义的规则执行相应的操作，比如给网卡命名，挂载硬盘，或执行一段自定义的脚本。

本文介绍由udev事件触发执行自定义的脚本。比如插入U盘。当理解了udev的工作原理后，可以做很多事情，比如插入一个无线网卡后就安装相应的驱动，插入指定的U盘就执行备份操作。



## udevadm命令

`udevadm`是一个管理udev的工具

```bash
udevadm
    info    # Qurey sysfs or the udev database
    control # Control the udev daemon    
    monitor # Listen to kernel and udev events
```

示例1： 查看硬盘`/dev/sda`udev信息

```bash
$ udevadm info -a -n /dev/sda
...
KERNEL=="sda"
    SUBSYSTEM=="block"
    DRIVER==""
    SUBSYSTEMS=="scsi"
    DRIVERS=="sd"
...
```

示例2： 查看udev事件

```bash
$ udevadm monitor
```

示例3： 当编写了一个新的udev规则，需要重新加载udev deamon

```bash
$ udevadm control --reload
```



## udev事件触发脚本执行

1. 编写脚本
   
   ```bash
   $ cat /opt/work/scripts/test.sh 
   #!/bin/bash
   echo "`date +%F_%T` hello world" >> /tmp/test.log
   
   # 给脚本执行权限
   $ chmod u+x /opt/work/scripts/test.sh
   ```

   

2. 编写udev规则
   
   ```bash
   $ cat /usr/lib/udev/rules.d/99-test.rules 
   SUBSYSTEM=="block", ACTION=="add", RUN+="/opt/work/scripts/test.sh"
   ```

此处我们规则匹配范围定义得很广，只有时块设备都匹配，当设备插入时产生add事件，就执行后面得脚本，可以执行命令`udevadm monitor`，然后插拔U盘，观看屏幕上面产生得udev事件



3. 重载`udev daemon` ,使定义得规则生效
   
   ```bash
   $ udevadm control --reload
   ```

4. 插入U盘，查看日志
   
   ```bash
   $ tail -f /tmp/test.log 
   2020-11-11_15:32:49 hello world
   2020-11-11_15:32:50 hello world
   2020-11-11_15:32:50 hello world
   ```



## 优化规则

上面得规则匹配任何块设备，这范围有点广，若我们只想匹配指定厂商得设备，该如何改呢？



插入U盘查看设备厂商标识符`idVentor`

方法1：

```bash
$ lsusb 
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 005: ID 06cb:00a2 Synaptics, Inc. 
Bus 001 Device 004: ID 04f2:b604 Chicony Electronics Co., Ltd 
Bus 001 Device 006: ID 8087:0a2a Intel Corp. 
Bus 001 Device 035: ID 13fe:5500 Kingston Technology Company Inc. 
Bus 001 Device 031: ID 1c4f:0034 SiGma Micro 
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub


# 上面 “Bus 001 Device 035: ID 13fe:5500 Kingston Technology Company Inc.”就是我得U盘
# 其中"13fe"就是idVendor，生产厂商标识
```

方法2：

```bash
$ udevadm info -a -n /dev/sdb | grep idVendor
    ATTRS{idVendor}=="13fe"
    ATTRS{idVendor}=="1d6b"
```



修改udev规则

```bash
cat /usr/lib/udev/rules.d/99-test.rules 
SUBSYSTEM=="block", ATTRS{idVendor}=="13fe", ACTION=="add", RUN+="/opt/work/scripts/test.sh"
```

重载`udev daemon`

```bash
$ udevadm control --reload
```

此时插入其他品牌得U盘就不会执行脚本
