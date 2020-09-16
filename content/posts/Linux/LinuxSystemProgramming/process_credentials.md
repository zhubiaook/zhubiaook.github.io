---
title: "进程凭证"
date: 2020-09-11
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "process_permission"
    identifier: "Linux.LinuxSystemProgramming.process_permission.md"
    parent: Linux.LinuxSystemProgramming
---

> 每个进程都有一套用数字表示的`useridentifiers(UIDs)`和`group identifiers(GIDs)`，这些ID称为进程的凭证，决定了进程的权限。

`UIDs`和`GIDs`包含以下几种：

* 实际用户ID：`real user ID(RUID)` 和实际组ID： `real group ID(RGID)`

* 有效用户ID：`effective user ID(EUID)` 和有效组ID： `effective group ID(EGID)`

* 保存set-user-ID：`saved set-user-ID(SUID)`和保存set-grop-ID：`saved set-group-ID(SGID)`

* 文件系统用户ID：`filesystem user ID(FUID)`和文件系统组ID：`filesystem group ID(FGID)`

* 附加组ID: `supplementary group IDs`

`FUID`和`FGID`通常与`EUID`和`EGID`一样，后文不再对其单独叙述。

## `UIDs`, `GIDs`作用

1. `RUID(RGID)`: 实际用户(组)ID决定了进程所属的用户和组（可能被进程执行的程序指令改变）。CentOS发行版上，当我们登录`bash`(即进入`bash`进程提供的命令行终端）时，登录程序会读取`/etc/passwd`文件对应用户的第三、第四字段的值作为`bash`进程的`RUID`和`RGID`，我们在bash里面执行的各种命令的`RUID`和`RGID`都继承自父进程`bash`。同样，当创建新进程时，该进程的`RUID`, `RGID`也继承自其父进程。

2. `EUID(EGID)`: 有效用户(组)ID决定了进程执行各种操作时所拥有的权限，通常`EUDI`等同于`RUID`，但以下两种情况会使其不一样：
   
   1. 当可执行文件（程序或命令）设置了`set-user-ID`,`set-group-ID`，则执行该程序时，进程的有效用户(组)ID会被改变为可执行文件的属主ID(属组ID)。若可执行文件属主、属组ID是`0`(比如root)，则进程就间接拥有了超级权限。
   
   2. 进程执行了`setuid()`之类的系统调用，改变了进程的有效用户ID。

3. `SUID(SGID)`：`save set-user-ID`的初值从`EUID`复制而来，通常配合`set-user-ID`标志位使用，设置了该标志位的程序启动后，进程的`EUID`为程序的属主ID，从而`save set-user-ID`的值也为程序属主ID，进程通过`seteuid()`等指令可以自由的将`EUID`设置为`RUID`或`save set-user-ID`。当进程需要执行特权操作时，将`EUID`设置为`save set-user-ID`而获得需要的权限，而执行普通操作时，将`EUID`设置为`RUID`，降低进程的权限，保证系统安全。

## 查看进程的`UIDs`,`GIDs`

通过`/proc/PID/status`文件可以查看进程此刻的`UIDs`和`GIDs`，要注意进程的这些ID不是静态不变的，可能被进程执行的程序指令改变（比如执行了setuid()之类的程序，或加载了了另外一个程序，该程序设置了`set-user-ID`，`set-group-ID`）。

```bash
$ cat /proc/$$/status | egrep 'Uid|Gid'
Uid:    1000    1000    1000    1000
Gid:    1000    1000    1000    1000
```

上面四个字段分别是：`RUID(RGID)`,`EUID(EGID)`, `SUID(SGID)`, `FUID(FGID)` 

## `UIDs`相关的系统调用

### `getuid(), geteuid()`

> `getuid()`
> 
> 获取进程当前的实际用户ID(RUID)
> 
> `geteuid()`
> 
> 获取进程当前的有效用户ID(EUID)

```bash
#include <stdio.h>
#include <unistd.h>

int main() {
    printf("GUID: %d, EUID: %d\n", getuid(), geteuid());
    return 0;
}
```

### `setuid()`, `seteuid()`

> `setuid(uid_t uid)`: 根据情况，非特权进程只能修改有效用户ID，而EUID为0的特权进程将`RUID`,`EUID`, `SUID`一并修改，并且这一操作是单向的，即所有特权将消失，再也不能使用`setuid(0)`等之类的系统调用将其修改为特权进程。
> 
> `seteuid(uid_t uid)`: 修改进程的有效ID(EUID)

**setuid()**

```c
#include <stdio.h>
#include <unistd.h>

int main() {
    int num;

    /* 若程序的属主ID是0, 并设置了set-user-ID, 即使普通用户调用程序，
     * 此时的进程EUID=0, 拥有了特权
     */
    printf("1. RUID: %d, EUID: %d\n", getuid(), geteuid());
    scanf("%d", &num);

    /* 此操作将导致进程的RUID, EUID, SUID均为3000 
     * 从此进程的特权消失，再也不能恢复
     */
    setuid(3000);
    printf("2. RUID: %d, EUID: %d\n", getuid(), geteuid());
    scanf("%d", &num);

    setuid(0);
    printf("3. RUID: %d, EUID: %d\n", getuid(), geteuid());
    scanf("%d", &num);
    return 0;
}
```

使用root编译程序，并设置`set-user-ID`

```bash
$ gcc test.c -o test
$ chmod u+s ./test
```

bash RUID为`2000`的普通用户执行`test`程序进行验证

```bash
$ ./test 
1. RUID: 2000, EUID: 0
1
2. RUID: 3000, EUID: 3000
2
3. RUID: 3000, EUID: 3000
3
```

**seteuid()**

若要想进程不丢失特权，在普通进程和特权进程之间自由切换，则使用`seteuid()`

```c
#include <stdio.h>
#include <unistd.h>

int main() {
    int num;

    /* 若程序的属主ID是0, 并设置了set-user-ID, 即使普通用户调用程序，
     * 此时的进程EUID=0, 拥有了特权
     */
    printf("1. RUID: %d, EUID: %d\n", getuid(), geteuid());
    scanf("%d", &num);

    /* 此操作只将EUID修改为3000 */
    seteuid(3000);
    printf("2. RUID: %d, EUID: %d\n", getuid(), geteuid());
    scanf("%d", &num);

    /* 恢复EUID为0 */
    setuid(0);
    printf("3. RUID: %d, EUID: %d\n", getuid(), geteuid());
    scanf("%d", &num);
    return 0;
}
```

使用root编译程序，并设置`set-user-ID`

```bash
$ gcc test.c -o test
$ chmod u+s ./test
```

bash RUID为`2000`的普通用户执行`test`程序进行验证，同时可以查看`/proc/PID/status`中记录的进程ID，程序中使用`scanf()`就是为了利用等待用户输入暂停进程往下执行。

```bash
$ ./test 
1. RUID: 2000, EUID: 0
1
2. RUID: 2000, EUID: 3000
2
3. RUID: 2000, EUID: 0
3
```

### 进程执行程序导致的`EUID`变化

进程加载了新的程序，进程`RUID`保持不变，但`EUID`有可能会改变，比如该程序设置了`set-user-ID`则进程加载该程序将导致自己的`EUID`改变为程序的属主ID。  

下面举例说明，如下执行`main`可执行文件启动了一个进程，接着进程执行了`execpl()`系统调用加载了新的程序`test`替换已有的后续程序。  

`main.c`

```c
#include <stdio.h>
#include <unistd.h>

int main(void) {
    int num;
    printf("main-porcess, RUID: %d, EUID: %d\n", getuid(), geteuid());
    scanf("%d", &num);
    execl("/tmp/test", "test", NULL);
    scanf("%d", &num);
}
```

`test.c`

```c
#include <stdio.h>
#include <unistd.h>

int main() {
    int num;

    /* 若程序的属主ID是0, 并设置了set-user-ID, 即使普通用户调用程序，
     * 此时的进程EUID=0, 拥有了特权
     */
    printf("test-process, RUID: %d, EUID: %d\n", getuid(), geteuid());
    scanf("%d", &num);
    return 0;
}
```

使用root编译min.c，test.c程序，并设置test可执行文件`set-user-ID`

```bash
$ gcc main.c -o main
$ gcc test.c -o test
$ chmod u+s ./test
```

bash RUID为`2000`的普通用户执行`main`程序进行验证

```bash
./main 
main-porcess, RUID: 2000, EUID: 2000
```

bash RUID为0: 此时观察`/proc/PID/status`得到同样的结果

```bash
$ pstree -p | grep main
           |-sshd(814)-+-sshd(2436)---bash(2440)---su(2992)---bash(2993)---main(8857)
$ egrep "Uid" /proc/8857/status
Uid:    2000    2000    2000    2000
```

bash RUID为2000：输入任意一个数字，让进程加载`test`可执行程序，发现`EUID`, `SUID`均变为0

```bash
1
test-process, RUID: 2000, EUID: 0
```

bash RUID为0: 此时观察`/proc/PID/status`得到同样的结果

```bash
egrep "Uid" /proc/8857/status
Uid:    2000    0    0    0
```
