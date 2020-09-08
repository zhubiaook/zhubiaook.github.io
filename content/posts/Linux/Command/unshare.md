---
title: "unshare"
date: 2020-09-08
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "unshare"
    identifier: "Linux.Command.unshare.md"
    parent: Linux.Command
---



> 用于Linux Namespace，`unshare` 命令可以创建一个新的Namespace，然后执行指定的程序，并将新的进程加入到新创建的Namespace中。新的Namespace支持多少种隔离，由unshare选项决定



## 语法

```bash
unshare [OPTIONS] COMMAND
```

`OPTIONS`:

* -m, --mount : CLONE_NEWNS

* -u, --uts : CLONE_NEWUTS

* -i, --ipc : CLONE_NEWIPC

* -n, --net : CLONE_NEWNET

* -p, --pid : CLONE_NEWPID

* -U, --user : CLONE_NEWUSER

* -f, --fork : 创建一个子进程执行COMMAND，而不是取代当前的进程

* -r, --map-root-user : 必须有-U选项，新命名空间中的用户为root

* --propagation slave|shared|private|unchanged : 挂载选项



## 示例

创建一个各命名空间都隔离的Namespace，行Namespace执行`bash`程序

```bash
unshare -m -u -i -n -p -U -f -r --propagation slave /bin/bash
```
