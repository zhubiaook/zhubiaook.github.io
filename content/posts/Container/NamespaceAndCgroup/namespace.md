---
title: "namespace"
date: 2020-09-07
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "namespace"
    identifier: "Container.NamespaceAndCgroup.namespace.md"
    parent: Container.NamespaceAndCgroup
---

## 知识准备

[进程管理](https://blog.zybz.fun/posts/linux/linuxsystemprogramming/process_management/)

[C语言语法](https://blog.zybz.fun/posts/c/c_syntax/)

[unshare](https://blog.zybz.fun/posts/linux/command/unshare/)

## Namesapce

当前Linux内核支持的7种Namespace

```
名称        宏定义             隔离内容
Cgroup      CLONE_NEWCGROUP   Cgroup root directory (since Linux 4.6)
IPC         CLONE_NEWIPC      System V IPC, POSIX message queues (since Linux 2.6.19)
Network     CLONE_NEWNET      Network devices, stacks, ports, etc. (since Linux 2.6.24)
Mount       CLONE_NEWNS       Mount points (since Linux 2.4.19)
PID         CLONE_NEWPID      Process IDs (since Linux 2.6.24)
User        CLONE_NEWUSER     User and group IDs (started in Linux 2.6.23 and completed in Linux 3.8)
UTS         CLONE_NEWUTS      Hostname and NIS domain name (since Linux 2.6.19)
```

查看当前bash进程所属的namespace（CentOS8.2)

```bash
$ ll /proc/$$/ns
total 0
lrwxrwxrwx 1 opt opt 0 Sep  7 19:04 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 opt opt 0 Sep  7 19:04 ipc -> 'ipc:[4026531839]'
lrwxrwxrwx 1 opt opt 0 Sep  7 19:04 mnt -> 'mnt:[4026531840]'
lrwxrwxrwx 1 opt opt 0 Sep  7 19:04 net -> 'net:[4026531992]'
lrwxrwxrwx 1 opt opt 0 Sep  7 19:04 pid -> 'pid:[4026531836]'
lrwxrwxrwx 1 opt opt 0 Sep  7 19:04 pid_for_children -> 'pid:[4026531836]'
lrwxrwxrwx 1 opt opt 0 Sep  7 19:04 user -> 'user:[4026531837]'
lrwxrwxrwx 1 opt opt 0 Sep  7 19:04 uts -> 'uts:[4026531838]'
```

## UTS隔离

修改主机名

```c
/*
 * int gethostname(char *name, int len);
 * int sethostname(char *name, int len);
 * 获取，设定主机名
 */

#include <unistd.h>
#include <stdio.h>

int main() {
    int ret;
    ret = sethostname("Slynxes", 8);
    if(ret == -1)
        perror("sethostname");
}
```

示例

```c
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

#define STACK_SIZE (1024 * 1024)

static char child_stack[STACK_SIZE];

int child_process() {
    printf("start child process ...\n");   
    /* 设置新的主机名 */
    sethostname("NewName", 7);
    /* 当前进程执行新的程序bash */
    execl("/bin/bash", "bash", NULL);
    /* 后面的程序将不会再执行，被bash程序取代，直到bash退出，该子进程执行完毕 */
    /* 子函数退出时返回的数据 */
    return 1;
}

int main(void) {
    int pid;
    printf("start process\n");  
    /* CLONE_NEWUTS: UTS隔离*/
    pid = clone(child_process, // 子进程执行的函数
                child_stack + STACK_SIZE, // 初始栈地址指向高位，因为栈是从高位向地位增长
                CLONE_NEWUTS | SIGCHLD, NULL);  // SIGCHLD与Namespace没关系，是子进程推出后返回给父进程的信号量
    /* 父进程继续执行后面的程序，子进程去执行child_process子函数，不再执行后面的程序 */
    waitpid(pid, NULL, 0);
    printf("process stopped\n");
}
```

上面的程序指向流程：

1. 上面程序启动的进程（父进程）调用`clone()`创建子进程，参数中由于指定`CLONE_NEWUTS` ，所以会创建`UTS Namespace` ，创建的子进程会加入该`UTS Namespace` 中。然后父进程阻塞等待子进程的退出。

2. 子进程转而执行`child_process`子函数，然后调用`execl` 转而执行`bash` 程序，此时终端上你会发现进入了一个新的`Shell`环境，主机名也改变了。此时你查看`ll /proc/Current_Bash_PID/ns/uts` 的Node值与父进程的不一样，说明父、子进程所在的UTS Namespace已经不相同。 直到你在终端上输入`exit`类似的命令才退出当前子进程。

3. 子进程退出后，父进程继续执行`clone()` 调用点后面的程序。

## IPC Namespace

```c
/*
 * 子进程收不到父进程中的信号量等
 * 父进程中执行：ipcmk -Q, 子进程中执行: ipcs将查看不到
 */
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

#define STACK_SIZE (1024 * 1024)

static char child_stack[STACK_SIZE];

int child_process() {
    printf("start child process ...\n");
    sethostname("NewName", 7);
    execl("/bin/bash", "bash", NULL);
    return 1;
}

int main(void) {
    int pid;

    printf("start process\n");
    /* CLONE_NEWIPC: IPC隔离*/
    pid = clone(child_process, child_stack + STACK_SIZE, CLONE_NEWIPC | CLONE_NEWUTS | SIGCHLD, NULL);
    waitpid(pid, NULL, 0);
    printf("process stopped\n");
}
```

## Net Namespace

1. `net-namespace`用来隔离进程的网络，每个`net-namespace`都拥有独立的网络设备、网络协议栈、路由，互不影响

2. 网络设备只能属于其中一个`net-namespace`，不能共享

3. 标记为`netns-local`的设备不能从一个`net-namespace`移到另外一个`net-namespace`，比如`bridge`, `lo`设备
   
   ```bash
   $ ethtool -k br0 | grep netns-local
   netns-local: on [fixed]
   ```

此部分的操作示例请查看[veth](https://blog.zybz.fun/posts/container/network/veth/)

#### `ip netns`

> `ip netns` 可以用来操作方便操作`net-namespace`，下面解释其命令

`ip netns add net-namespace01`命令可以通过下面的脚本实现

```bash
# 创建新的net namespace
$ unshare -n /bin/bash
# 绑定当前net-namespace到文件上，/var/run/netns为ip netns默认的目录
$ touch /var/run/netns/net-namespace01
$ mount --bind /proc/$$/ns/net /var/run/netns/net-namespace01
# 可以看到该文件的inode节点就是net的inode节点
$ ls -i /var/run/netns/net-namespace01
4026532421 /var/run/netns/net-namespace01 
$ readlink /proc/$$/ns/net
net:[4026532421]
```

`ip netns exec net-namespace01 /bin/bash`命令可以通过以下脚本实现

```bash
nsenter --net=/var/run/netns/net-namespace01 /bin/bash
```

## PID Namespace

1. `PID Namespace`用来隔离进程PID，使得不同Namespace中的PID可以重复，且相互不影响。

2. `PID Namespace`可以嵌套，当前`PID Namespace`中创建的新`PID Namespace`均属于其子`PID Namespace`，父`PID Namespace`可以查看到子`PID Namespace`中所有进程信息，但子`PID Namespace`不能查看父的进程信息，包括兄弟的都不行。同一个进程在父、子Namespace中看到的进程PID是不一样的。

3. 每个Namespace都可以通过`/proc` 目录查看当前`Namespace`及其子孙`Namespace`的进程信息。

4. 每个Namespace中创建的第一个进程，在当前Namespace视图中进程PID为1，其子进程均由该进程创建，当子进程的父进程挂掉，则由当前Namespace中PID为1的进程接管，做其父进程。记住不是父Namespace中的PID=1的进程，而是当前。当PID=1的进程也挂断，则该Namespace中的所有进程都会收到自杀信号`SIGKILL`而自行了断，随之Namespace也被摧毁。

5. 已创建的进程无法改变其PID Namespace, 只有新创建的进程才可以指定PID Namespace

**示例**

> 通过系统调用演示

```c
/*
 * 进入子进程后执行命令：echo $$， 会发现当前进程ID为1
 */

#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

#define STACK_SIZE (1024 * 1024)

static char child_stack[STACK_SIZE];

int child_process() {
    printf("start child process ...\n");
    sethostname("NewName", 7);
    execl("/bin/bash", "bash", NULL);
    return 1;
}

int main(void) {
    int pid;

    printf("start process\n");
    /* NEW_PID: PID隔离 */
    pid = clone(child_process, child_stack + STACK_SIZE, CLONE_NEWPID | CLONE_NEWIPC | CLONE_NEWUTS | SIGCHLD, NULL);
    waitpid(pid, NULL, 0);
    printf("process stopped\n");
}
```

重新挂载proc

经过上面的隔离，你会发现使用ps, top命令仍然可以看到父进程中namespace空间中的进程信息，这是因为文件系统还没有隔离，这些命令查询的是父进程/proc目录下的文件。

```
# 重新挂载proc
mount -t proc proc /proc

# 此时再使用ps等进程查看命令，就只有子namespce空间中的进程信息了
```

> 通过Linux命令`unshare`
> 
> -f 创建新的进程加入新创建的PID Namespace中，unshare程序启动的进程仍然在老的PID Namespace中
> 
> --mount-proc: 执行重新挂载proc，不重新mount proc的话，读到的进程信息仍然是父PID Name中的

```bash
unshare -p -u -m -f --mount-proc /bin/bash
```

### Mount Namespace

Mount namespaces是第一个被加入Linux的namespace，由于当时没想到还会引入其它的namespace，所以取名为CLONE_NEWNS，而没有叫CLONE_NEWMOUNT。

```c
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

#define STACK_SIZE (1024 * 1024)

static char child_stack[STACK_SIZE];

int child_process() {
    printf("start child process ...\n");
    sethostname("NewName", 7);
    execl("/bin/bash", "bash", NULL);
    return 1;
}

int main(void) {
    int pid;

    printf("start process\n");
    /* CLONE_NEWNS: Mount隔离 */
    pid = clone(child_process, child_stack + STACK_SIZE, CLONE_NEWNS | CLONE_NEWPID | CLONE_NEWIPC | CLONE_NEWUTS | SIGCHLD, NULL);
    waitpid(pid, NULL, 0);
    printf("process stopped\n");
}
```

## User Namespace

```c
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>
#define STACK_SIZE (1024 * 1024)

static char child_stack[STACK_SIZE];

void set_uid_map(int pid, int inside_id, int outside_id, int length) {
    char path[256];
    sprintf(path, "/proc/%d/uid_map", getpid());
    FILE* uid_map = fopen(path, "w");
    fprintf(uid_map, "%d %d %d", inside_id, outside_id, length);
    fclose(uid_map);
}

void set_gid_map(int pid, int inside_id, int outside_id, int length) {
    char path[256];
    sprintf(path, "/proc/%d/gid_map", getpid());
    FILE* gid_map = fopen(path, "w");
    fprintf(gid_map, "%d %d %d", inside_id, outside_id, length);
    fclose(gid_map);
}


int child_process() {
    printf("start child process ...\n");
    set_uid_map(getpid(), 0, 1000, 1);
    set_gid_map(getpid(), 0, 1000, 1);
    printf("EUID: %d, EGID: %d\n", geteuid(), getegid());
    sethostname("NewName", 7);
    execl("/bin/bash", "bash", NULL);
    return 1;
}

int main(void) {
    int pid;

    printf("start process\n");
    /* CLONE_NEWUSER: USER隔离 */
    pid = clone(child_process, child_stack + STACK_SIZE, CLONE_NEWUSER | SIGCHLD, NULL);
    waitpid(pid, NULL, 0);
    printf("process stopped\n");
    return 0;
}
```

### 用户ID和组ID

进程相关的uid, gid

```
uid/ruid, gid/rgid: 运行进程的用户和组
euid, egid: 进程当前的uid和gid, 决定进程能够获取到哪些系统资源
saved uid, saved gid: 进程原有的有效用户uid,gid
```

示例

```c
/*
 * 修改用户真实uid，gid: int setuid(int uid); int setgid(int gid);
 * 修改用户有效euid, egid: int seteuid(int uid), int setegid(int egid);
 * 获取uid, gid: int getuid(); int getgid();
 */

#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(void) {
    int status;
    int pid;

    // 修改真实用户uid为1001
    setuid(1001);
    printf("%d", getuid);    
    if(fork() == 0) {
        // 修改子进程用户有效uid为 1002

        seteuid(1002);
        execl("/usr/bin/sleep", "sleep", "100", NULL);
    }
```

## 参考文档

[Linux Namespace和Cgroup - Linux程序员 - SegmentFault 思否](https://segmentfault.com/a/1190000009732550)

[Docker背后的内核知识——Namespace资源隔离-InfoQ](https://www.infoq.cn/article/docker-kernel-knowledge-namespace-resource-isolation)
