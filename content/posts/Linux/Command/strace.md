---
title: "strace"
date: 2020-09-08
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "strace"
    identifier: "Linux.Command.strace.md"
    parent: Linux.Command
---



> `strace` 最简单的用法是，指定一个要执行的命令，命令结束后它也退出。在命令的执行过程中，strace会记录和解析命令进程的所有系统调用，和该进程收到的信号量。

## 语法

```bash
strace [OPTIONS] COMMAND
```



## 示例

```bash
strace -o record.txt -f ls
```
