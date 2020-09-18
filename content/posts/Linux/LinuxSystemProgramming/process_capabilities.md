---
title: "process_capabilities"
date: 2020-09-15
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "process_capabilities"
    identifier: "Linux.LinuxSystemProgramming.process_capabilities.md"
    parent: Linux.LinuxSystemProgramming
---

## capabilities概述

传统的`UNIX`系统将进程分为两类：

- `provileged`特权进程：`effective user ID`是0的进程，内核对此类进程跳过所有权限检查，即有权限执行任何操作。

- `unprivileged`非特权进程：`effective user ID`不是0的进程，内核对此类进程进行全面权限检查，根据`effective UID, effective GID, supplementary grop list`决定是否有权限执行某项操作。

传统`UNIX`对于普通进程执行特权操作就必须使进程的`effective user ID`为0(通过set-user-ID)，如此进程就拥有了所有特权，若进程执行非法或意外操作将导致严重破坏。为了安全Linux-kernel-2.2后将特权(以前属于effective user ID = 0的)拆分为不同的细小单元。一个单元只拥有一部分特权。这些单元就是`capabilities`，其实`capabilities`是属于线程的特性，也就是可以给线程分配不同的`capability`。

## capabilites 列表

| capability 名称        | 描述                                          |
| -------------------- | ------------------------------------------- |
| CAP_AUDIT_CONTROL    | 启用和禁用内核审计；改变审计过滤规则；检索审计状态和过滤规则              |
| CAP_AUDIT_READ       | 允许通过 multicast netlink 套接字读取审计日志            |
| CAP_AUDIT_WRITE      | 将记录写入内核审计日志                                 |
| CAP_BLOCK_SUSPEND    | 使用可以阻止系统挂起的特性                               |
| CAP_CHOWN            | 修改文件所有者的权限                                  |
| CAP_DAC_OVERRIDE     | 忽略文件的 DAC 访问限制                              |
| CAP_DAC_READ_SEARCH  | 忽略文件读及目录搜索的 DAC 访问限制                        |
| CAP_FOWNER           | 忽略文件属主 ID 必须和进程用户 ID 相匹配的限制                 |
| CAP_FSETID           | 允许设置文件的 setuid 位                            |
| CAP_IPC_LOCK         | 允许锁定共享内存片段                                  |
| CAP_IPC_OWNER        | 忽略 IPC 所有权检查                                |
| CAP_KILL             | 允许对不属于自己的进程发送信号                             |
| CAP_LEASE            | 允许修改文件锁的 FL_LEASE 标志                        |
| CAP_LINUX_IMMUTABLE  | 允许修改文件的 IMMUTABLE 和 APPEND 属性标志             |
| CAP_MAC_ADMIN        | 允许 MAC 配置或状态更改                              |
| CAP_MAC_OVERRIDE     | 忽略文件的 DAC 访问限制                              |
| CAP_MKNOD            | 允许使用 mknod() 系统调用                           |
| CAP_NET_ADMIN        | 允许执行网络管理任务                                  |
| CAP_NET_BIND_SERVICE | 允许绑定到小于 1024 的端口                            |
| CAP_NET_BROADCAST    | 允许网络广播和多播访问                                 |
| CAP_NET_RAW          | 允许使用原始套接字                                   |
| CAP_SETGID           | 允许改变进程的 GID                                 |
| CAP_SETFCAP          | 允许为文件设置任意的 capabilities                     |
| CAP_SETPCAP          | 参考 capabilities man page                    |
| CAP_SETUID           | 允许改变进程的 UID                                 |
| CAP_SYS_ADMIN        | 允许执行系统管理任务，如加载或卸载文件系统、设置磁盘配额等               |
| CAP_SYS_BOOT         | 允许重新启动系统                                    |
| CAP_SYS_CHROOT       | 允许使用 chroot() 系统调用                          |
| CAP_SYS_MODULE       | 允许插入和删除内核模块                                 |
| CAP_SYS_NICE         | 允许提升优先级及设置其他进程的优先级                          |
| CAP_SYS_PACCT        | 允许执行进程的 BSD 式审计                             |
| CAP_SYS_PTRACE       | 允许跟踪任何进程                                    |
| CAP_SYS_RAWIO        | 允许直接访问 /devport、/dev/mem、/dev/kmem 及原始块设备   |
| CAP_SYS_RESOURCE     | 忽略资源限制                                      |
| CAP_SYS_TIME         | 允许改变系统时钟                                    |
| CAP_SYS_TTY_CONFIG   | 允许配置 TTY 设备                                 |
| CAP_SYSLOG           | 允许使用 syslog() 系统调用                          |
| CAP_WAKE_ALARM       | 允许触发一些能唤醒系统的东西(比如 CLOCK_BOOTTIME_ALARM 计时器) |

## 相关系统调用

```c
cap_t cap_get_proc() // 获取当前进程的capalibities
cap_t cap_get_pid(pid_t pid) // 获取指定进程的capalibities
cap_t cap_from_text(char *buf_p) // 将文本转化为capablibities
char *cap_to_text(cap_t caps, ssize_t *length_p) // 将capalibities转为文本
int cap_from_name(char *name, int *cap_p) // 将字符串表示的capability转为对应的数字
char *cap_to_name(int cap) // 将cap的数字转为文本

int cap_get_flag(cap_t cap_p, cap_value_t cap, cap_flag_t flag, cap_flag_value_t *value_p); // 设置能力，配合cap_set_proc()使用
int cap_set_proc(cap_t cap_p) //设置当前进程的能力
cap_t cap_init() // creates a capability state
int cap_free() // 释放capability state内存
```

## 获取、修改文件capability的命令

获取文件capabilities

```bash
$ getcap /usr/bin/ping
/usr/bin/ping = cap_net_admin,cap_net_raw+p
```

设置文件capabilities

```bash
setcap 'cap_net_admin+ep cap_net_raw+ei' /tmp/cap/sleep
```

## 执行`exec()`之类的系统调用，capabilities变化如下：

> ambient capability set 是Linux 4.3后才有
> 
> Linux 2.6.25, the bounding set was a system-wide attribute shared by all threads.

```
P'(ambient)     = (file is privileged) ? 0 : P(ambient)
P'(permitted)   = (P(inheritable) & F(inheritable)) | (F(permitted) & P(bounding)) | P'(ambient)
P'(effective)   = F(effective) ? P'(permitted) : P'(ambient)
P'(inheritable) = P(inheritable)
P'(bounding)    = P(bounding)
```

## 执行`fork()`等创建进程的系统调用，capabilities继承父进程的

## 示例

提前安装好相关依赖库

```bash
yum -y install libcap-devel libcap-ng-devel
```

打印当前进程的capabilities

```c
#include <sys/capability.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    pid_t pid;
    cap_t cap;
    cap_value_t cap_list[CAP_LAST_CAP+1];
    cap_flag_t cap_flags;
    cap_flag_value_t cap_flags_value;

    const char *cap_name[CAP_LAST_CAP+1] = {
        "cap_chown",
        "cap_dac_override",
        "cap_dac_read_search",
        "cap_fowner",
        "cap_fsetid",
        "cap_kill",
        "cap_setgid",
        "cap_setuid",
        "cap_setpcap",
        "cap_linux_immutable",
        "cap_net_bind_service",
        "cap_net_broadcast",
        "cap_net_admin",
        "cap_net_raw",
        "cap_ipc_lock",
        "cap_ipc_owner",
        "cap_sys_module",
        "cap_sys_rawio",
        "cap_sys_chroot",
        "cap_sys_ptrace",
        "cap_sys_pacct",
        "cap_sys_admin",
        "cap_sys_boot",
        "cap_sys_nice",
        "cap_sys_resource",
        "cap_sys_time",
        "cap_sys_tty_config",
        "cap_mknod",
        "cap_lease",
        "cap_audit_write",
        "cap_audit_control",
        "cap_setfcap",
        "cap_mac_override",
        "cap_mac_admin",
        "cap_syslog"
    };

    pid = getpid();
    cap = cap_get_pid(pid);
    if (cap == NULL) {
        perror("cap_get_pid");
        exit(-1);
    }

    /* effetive cap */
    cap_list[0] = CAP_CHOWN;
    if (cap_set_flag(cap, CAP_EFFECTIVE, 1, cap_list, CAP_SET) == -1) {
        perror("cap_set_flag cap_chown");
        cap_free(cap);
        exit(-1);
    }

    /* permitted cap */
    cap_list[0] = CAP_MAC_ADMIN;
    if (cap_set_flag(cap, CAP_PERMITTED, 1, cap_list, CAP_SET) == -1) {
        perror("cap_set_flag cap_mac_admin");
        cap_free(cap);
        exit(-1);
    }

    /* inherit cap */
    cap_list[0] = CAP_SETFCAP;
    if (cap_set_flag(cap, CAP_INHERITABLE, 1, cap_list, CAP_SET) == -1) {
        perror("cap_set_flag cap_setfcap");
        cap_free(cap);
        exit(-1);
    }

        /* dump them */
    int i;
    for (i=0; i < CAP_LAST_CAP + 1; i++) {
        cap_from_name(cap_name[i], &cap_list[i]);
        printf("%-20s %d\t\t", cap_name[i], cap_list[i]);
        printf("flags: \t\t");
        cap_get_flag(cap, cap_list[i], CAP_EFFECTIVE, &cap_flags_value);
        printf(" EFFECTIVE %-4s ", (cap_flags_value == CAP_SET) ? "OK" : "NOK");
        cap_get_flag(cap, cap_list[i], CAP_PERMITTED, &cap_flags_value);
        printf(" PERMITTED %-4s ", (cap_flags_value == CAP_SET) ? "OK" : "NOK");
        cap_get_flag(cap, cap_list[i], CAP_INHERITABLE, &cap_flags_value);
        printf(" INHERITABLE %-4s ", (cap_flags_value == CAP_SET) ? "OK" : "NOK");
        printf("\n");
    }

    cap_free(cap);

    return 0;
}
```

给进程赋予能力

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#undef _POSIX_SOURCE
#include <sys/capability.h>

extern int errno;

void whoami(void)
{
  printf("uid=%i  euid=%i  gid=%i\n", getuid(), geteuid(), getgid());
}

void listCaps()
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#undef _POSIX_SOURCE
#include <sys/capability.h>

extern int errno;

void whoami(void)
{
  printf("uid=%i  euid=%i  gid=%i\n", getuid(), geteuid(), getgid());
}

void listCaps()
{
  cap_t caps = cap_get_proc();
  ssize_t y = 0;
  printf("The process %d was give capabilities %s\n",
         (int) getpid(), cap_to_text(caps, &y));
  fflush(0);
  cap_free(caps);
}

int main(int argc, char **argv)
{
  int stat;
  whoami();
  stat = setuid(geteuid());
  pid_t parentPid = getpid();

  if(!parentPid)
    return 1;
  cap_t caps = cap_init();


  cap_value_t capList[5] = { CAP_NET_RAW, CAP_NET_BIND_SERVICE , CAP_SETUID, CAP_SETGID, CAP_SETPCAP };
  unsigned num_caps = 5;
  cap_set_flag(caps, CAP_EFFECTIVE, num_caps, capList, CAP_SET);
  cap_set_flag(caps, CAP_INHERITABLE, num_caps, capList, CAP_SET);
  cap_set_flag(caps, CAP_PERMITTED, num_caps, capList, CAP_SET);

  if (cap_set_proc(caps)) {
    perror("capset()");

    return EXIT_FAILURE;
  }

  listCaps();

  printf("dropping caps\n");
  cap_clear(caps);  // resetting caps storage

  if (cap_set_proc(caps)) {
    perror("capset()");
    return EXIT_FAILURE;
  }
  listCaps();

  cap_free(caps);
  return 0;
}
```

上面两个示例编译方法

```bash
gcc -lcap FILE.c -o FILE
```

Ambient能力是Linux 4.3后面才有

```c
/*
 * Test program for the ambient capabilities. This program spawns a shell
 * that allows running processes with a defined set of capabilities.
 *
 * (C) 2015 Christoph Lameter <cl@linux.com>
 * Released under: GPL v3 or later.
 *
 *
 * Compile using:
 *
 *  gcc -o ambient_test ambient_test.o -lcap-ng
 *
 * This program must have the following capabilities to run properly:
 * Permissions for CAP_NET_RAW, CAP_NET_ADMIN, CAP_SYS_NICE
 *
 * A command to equip the binary with the right caps is:
 *
 *  setcap cap_net_raw,cap_net_admin,cap_sys_nice+p ambient_test
 *
 *
 * To get a shell with additional caps that can be inherited by other processes:
 *
 *  ./ambient_test /bin/bash
 *
 *
 * Verifying that it works:
 *
 * From the bash spawed by ambient_test run
 *
 *  cat /proc/$$/status
 *
 * and have a look at the capabilities.
 */

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <cap-ng.h>
#include <sys/prctl.h>
#include <linux/capability.h>

/*
 * Definitions from the kernel header files. These are going to be removed
 * when the /usr/include files have these defined.
 */
#define PR_CAP_AMBIENT 47
#define PR_CAP_AMBIENT_IS_SET 1
#define PR_CAP_AMBIENT_RAISE 2
#define PR_CAP_AMBIENT_LOWER 3
#define PR_CAP_AMBIENT_CLEAR_ALL 4

static void set_ambient_cap(int cap)
{
    int rc;

    capng_get_caps_process();
    rc = capng_update(CAPNG_ADD, CAPNG_INHERITABLE, cap);
    if (rc) {
        printf("Cannot add inheritable cap\n");
        exit(2);
    }
    capng_apply(CAPNG_SELECT_CAPS);

    /* Note the two 0s at the end. Kernel checks for these */
    if (prctl(PR_CAP_AMBIENT, PR_CAP_AMBIENT_RAISE, cap, 0, 0)) {
        perror("Cannot set cap");
        exit(1);
    }
}

int main(int argc, char **argv)
{
    int rc;

    set_ambient_cap(CAP_NET_RAW);
    set_ambient_cap(CAP_NET_ADMIN);
    set_ambient_cap(CAP_SYS_NICE);

    printf("Ambient_test forking shell\n");
    if (execv(argv[1], argv + 1))
        perror("Cannot exec");

    return 0;
}
```

编译

```bash
gcc -lcap-ng FILE.c -o FILE
```

## 参考文档

[capabilities(7) - Linux manual page](https://man7.org/linux/man-pages/man7/capabilities.7.html)

[cap_set_proc(3) - Linux manual page](https://www.man7.org/linux/man-pages/man3/cap_set_proc.3.html)

[cap_from_text(3) - Linux man page](https://linux.die.net/man/3/cap_from_text)

[Capability &#x6982;&#x8FF0; &#xB7; linux-capability](https://0x0916.gitbooks.io/linux-capability/content/chapter1.html)
