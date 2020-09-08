---
title: "文件IO管理"
date: 2020-09-07
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "file_io_management"
    identifier: "Linux.LinuxSystemProgramming.file_io_management.md"
    parent: Linux.LinuxSystemProgramming
---



# 文件读写 - 系统调用

> `int open(const char *name, int flags, mode_t mode);`
> 
> flags: O_RDONLY, O_WRONLY, O_RDWR, O_CREAT, ...

```c
#include <fcntl.h>
#include <stdio.h>

int main(void) {
    int fd;
    fd = open("/opt/c/hello.txt", O_RDONLY);

    if (fd == -1)
        perror("Error");
    else
        printf("%d", fd);
}
```



> `int create(const char *name, mode_t mode);` 

```c
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>

int main(void) {
    int fd;
    fd = creat("/opt/c/1.txt", 0644);

    // 等同于
    // fd = open("/opt/c/1.txt", O_WRONLY | O_CREATE | O_TRUNC, 0644);
    return 0;
}
```



> `int read(int fd, void *buf, int len);`

```c
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

int main(void) {
    char word[100];
    int nr, fd;
    fd = open("/opt/c/hello.txt", O_RDONLY);

    nr = read(fd, word, 7);
    printf("%s", word);
    close(fd);

    return 0;
}
```



> `int write(int fd, const void *buf, int count);`

```c
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(void) {
    int fd;
    char *buf = "My ship is solid!";

    fd = open("/opt/c/1.txt", O_RDWR);
    write(fd, buf, strlen(buf));
    close(fd);
    return 0;
}
```





# 同步IO

```c
/*
 * int fsync(int fd);
 * 对当前打开的fd缓冲区数据同步到磁盘
 */

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(void) {
    int fd, nr;
    char *buf = "Something so beautiful!!";

    fd = open("/opt/c/1.txt", O_RDWR);
    nr = write(fd, buf, strlen(buf));

    if(nr == -1) {
        perror("Error");
    } else {
        fsync(fd);
        printf("writed sucessful");
    }
    close(fd);
    return 0;
}
```

    writed sucessful

```c
/*
 * void sync(void);
 * 将磁盘上所有缓冲区的数据同步到磁盘
 */

#include <unistd.h>

int main(void) {
    sync();
    return 0;
}
```

    /tmp/tmprzt81yif.c: In function ‘main’:
    /tmp/tmprzt81yif.c:11:5: warning: implicit declaration of function ‘sync’ [-Wimplicit-function-declaration]
         sync();
         ^

# IO多路复用

## select

```c
/*
 * 测试select的使用，此处只监控一个I/O(标准输入)，并不是多路复用
 * 需要到Linux终端上运行
 * int select(int n, fd_set *readfs, fd_set *writefds, fd_set *execptfds, struct timeval *timeout);
 *   n: 监控集合中的最大文件描述符 + 1
 *   timeout: 
        struct timeval {
             long tv_sec; //seconds
             long tv_usec; //microseconds
        }
 * 当监控的文件描述符I/O未就绪，且处于设定的超时范围内，select()调用就一直阻塞。
 * 监控的文件描述符分为3类, 不监控的设置位NULL：
 *   1. readfds: 监控是否数据可读取
 *   2. writefds: 监控是否写操作可以无阻塞的完成
 *   3. exceptfds: 监控是否发生异常
 * FD_ZERO() 从指定集合中删除文件描述符
 * FD_SET() 向指定集合中添加文件描述符
 * FD_ISSET() 判读一个文件描述符是否在指定的集合中
 */

#include <stdio.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

#define TIMEOUT 5
#define BUF_LEN 1024
#define STDIN_FILENO 0

int main(void) {
    struct timeval tv;
    fd_set readfds;
    int ret;

    // wait on stdin for input.
    FD_ZERO(&readfds);
    FD_SET(STDIN_FILENO, &readfds);

    // wait up to five seconds
    tv.tv_sec = TIMEOUT;
    tv.tv_usec = 0;

    // all right, nou block!
    ret = select(
        STDIN_FILENO + 1,
        &readfds,
        NULL,
        NULL,
        &tv);

    if(ret == -1) {
        perror("select");
        return 1;
    } else if(!ret) {
        printf("%d seconds elapsed.\n", TIMEOUT);
        return 0;
    }

    // is our file descriptor ready to read?
    if(FD_ISSET(STDIN_FILENO, &readfds)) {
        char buf[BUF_LEN+1];
        int len;
        len = read(STDIN_FILENO, buf, BUF_LEN);
        if(len == -1) {
            perror("read");
            return 1;
        } else if(len) {
            buf[len] = '\0';
            printf("read: %s\n", buf);
        }
        return 0;
    }
    fprintf(stderr, "This should not happen!\n");
    return 1;
}
```

## poll

```c
/*
 * int poll(struct pollfd *fds, int nfds, int timeout);
     fds: 结构体数组，可以向poll传递多个监控结构体
     nfds: 传递的监控结构体个数
     timeout: 超时时长，单位ms
 */
#include <stdio.h>
#include <unistd.h>
#include <poll.h>

#define TIMEOUT 5

int main(void) {
    struct pollfd fds[2];
    int ret;

    // watch stdin for input
    fds[0].fd = STDIN_FILENO;
    fds[0].events = POLLIN;

    // watch stdout for ability to write
    fds[1].fd = STDIN_FILENO;
    fds[1].events = POLLOUT;

    // all set, block, timeout单位是ms
    ret = poll(fds, 2, TIMEOUT*1000);
    if(ret == -1) {
        perror("poll");
        return 1;
    }

    if(!ret) {
        printf("%d seconds elapsed.\n", TIMEOUT);
        return 0;
    }

    if(fds[0].revents & POLLIN) {
        printf("stdin is readable\n");
    }

    if (fds[1].revents & POLLOUT) {
        printf("stdout is writeable\n");
    }
    return 0;
}
```

# 文件读写 - C标准库

fopen, fread, fwrite是由C标准库(stdio.h)提供的C库函数

```c
/*
 * FILE *fopen(char *path, char *mode)
 */
#include <stdio.h>

int main(void) {
    FILE *stream;

    // 打开文件流
    stream = fopen("/opt/c/1.txt", "r");
    if(!stream) {
        perror("open");
    }

    // 关闭文件流
    fclose(stream);
}
```

```c
/*
 * int fread(void *buf, int size, int nr, FILE *stream)
 */
#include <stdio.h>

int main(void) {
    char buf[8];
    int nr;
    FILE *stream;

    stream = fopen("/opt/c/1.txt", "r");
    if(stream)
        nr = fread(buf, sizeof(buf), 1, stream);

    if(nr)
        printf("%s", buf);
    fclose(stream);
}
```

```c
/*
 * int fwrite(void *buf, int size, int nr, FILE *stream)
 */
#include <stdio.h>
#include <string.h>

int main(void) {
    char buf[100];
    int nr;
    FILE *stream;

    strcpy(buf, "hello, This is beautiful");

    stream = fopen("/opt/c/1.txt", "w");
    if(stream)
        nr = fwrite(buf, sizeof(buf), 1, stream);

    if(nr)
        printf("write sucessfully");
    fclose(stream);
}
```

    write sucessfully

```c
/*
 * fopen, fread, fwrite, fclose综合练习
 */

#include <stdio.h>

int main(void) {
    FILE *in, *out;

    struct person {
        char name[50];
        unsigned long weight;
        char gender;
    } zy, zb = {"zhubiao", 80, 'M'};

    out = fopen("/opt/c/2.txt", "w");
    if(!out) {
        perror("fopen");
        return 1;
    }

    if(!fwrite(&zb, sizeof(struct person), 1, out)) {
        perror("fread");
        return 1;
    }

    if(fclose(out)) {
        perror("fclose");
        return 1;
    }

    in = fopen("/opt/c/2.txt", "r");
    if(!in) {
        perror("fopen");
        return 1;
    }

    if(!fread(&zy, sizeof(struct person), 1, in)) {
        perror("fread");
        return 1;
    } else {
        printf("%s, %c, %d", zy.name, zy.gender, zy.weight);
    }

    if(fclose(in)){
        perror("fclose");
        return 1;
    }

}
```

    zhubiao, M, 80

# 存储映射

存储映射是将文件映射到内存中，对文件的读写操作变成对该内存区域的数据的访问，这样做的优点：

```
a. 使用fread, fwrite涉及到两次拷贝：从内核缓冲区到用户缓冲区，从用户缓冲区到用户读写区域；而使用映射是直接对映射区域进行读写操作
b. 读写映省去系统调用、上下文切换的开销
c. 当多个进程将同一个对象映射到内存中共享时，数据在所有内存间共享
d. 映射对象间搜索时，只是简单的指针操作，不需要系统调用lseek()
```

> mmap()

```c
/*
 * void * mmap(void, *addr, int len, int prot, int flags, int fd, int offset);
     调用成功返回内存映射的起始地址，失败返回-1
     addr: 告诉内核映射文件的最佳内存地址，不是强制性要求，传0由系统决定。
     len: 映射len个字节
     prot: 控制映射内存区域的访问权限, 不能与文件描述符fd冲突。
         PROT_READ: 页可读
         PROT_WRITE: 页可写
         PROT_EXEC: 页可执行
     flags:
         MAP_FIXED: 强制使用addr参数，如果无法映射到指定的内存区域，调用失败，不建议使用
         MAP_PRIVATE: 映射区域不共享
         MAP_SHARED: 映射区域共享，该映射区域会受其他进行写操作的影响。

    int munmap(void *addr, size_t len)
        调用成功返回0， 失败返回-1
        addr: 需取消的内存映射区域首地址，通常是mmap返回的地址

    int msync(void *addr, size_t len, int flags);
        将映射区域的数据同步到硬盘，等同于fsync()
 */

#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

int main(void) {
    int fd;
    void *p;
    int len;
    len = 5;

    fd = open("/opt/c/1.txt", O_RDONLY);  

    // 存储映射
    p = mmap(0, len, PROT_READ, MAP_SHARED, fd, 0);
    printf("%s", p);

    // 将映射同步到硬盘
    msync(p, len, MS_SYNC);

    // 取消映射
    munmap(p, len);
    // 此时再读取该内存区域会报错， printf("%s", p);
    return 0;

    printf("%d", MAP_FAILED);
}
```

    hello world
    someting so beautiful
