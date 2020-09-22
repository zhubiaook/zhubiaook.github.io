---
title: "内存相关的系统调用"
date: 2020-09-07
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "memory_management"
    identifier: "Linux.LinuxSystemProgramming.memory_management.md"
    parent: Linux.LinuxSystemProgramming
---

## 内存结构

# 动态内存分配

>  `void *malloc(int size);`  
> 
> 动态分配内存， 单位字节

```c
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main(void) {
    char *p, ret;
    p = malloc(2048);
    if(!p)
        perror("malloc");

    ret = execl("/usr/bin/ping", "ping", "www.baidu.com", NULL);
    if(ret == -1)
        perror("execl");
}
```

> `void *calloc(int nr, int size);`
> 
>  为数组分配内存，且将分配到的内存置为0

```c
#include <stdlib.h>
#include <stdio.h>

int main(void) {
    int *x, *y;

    /* 以下两种方法分配到的内存一样大 */
    x = malloc(256*sizeof(int));
    if(!x) {
        perror("malloc");
        return -1;
    }

    /* 将分配到的内存置为0 */
    y = calloc(256, sizeof(int));
    if(!y) {
        perror("malloc");
        return -1;
    }    
}
```

> `void *realloc(void *ptr, int size);` 
> 
> 重新分配内存，若内存大于原来的，可能涉及到数据拷贝
> 
> `void free(void, *ptr);` 
> 
> 释放内存

```c
#include <stdlib.h>
#include <stdio.h>

struct person {
    char name[10];
    char gender;
};

int main(void) {
    int *r;
    struct person *p;

    p = calloc(2, sizeof(struct person));
    if(!p) {
        perror("calloc");
        return -1;
    }

    /* 重新分配内存, p指向的内存将被释放 */
    r = realloc(p, sizeof(struct person));
    if(!r) {
        perror("realloc");
        return -1;
    }

    /* 释放内存 */
    free(r);
}
```

```c
#include <stdlib.h>
#include <stdio.h>

int main() {
    char *p;

    /* 将指针p指向分配的内存区域，就可以在该内存存储数据了 */
    p = calloc(2, sizeof(char));
    p[0] = 'a';

    free(p);
}
```

## Valgrind 检测内存错误

```bash
$ gcc -g source.c -o source
$ valgrind --tool=memcheck ./source
```

### 使用未初始化内存

```c
#include <stdio.h>

int main(void) {
    int a[3], b;
    b = a[0];
}
```

### 内存读写越界

```c
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int *p, len;

    len = 3;
    p = malloc(len*sizeof(int));
    p = p + len;
    *p = 10;
}
```

### 内存覆盖

```c
#include <string.h>
#include <stdlib.h>

int main(void) {
    char x[50];
    int i;

    for(i=0; i<50; i++) {
        x[i] = i + 1;
    }

    strncpy(x+20, x, 21);
    return 0;
}
```

### 内存泄漏

```c
#include <stdlib.h>

int main(void) {
    int *p = malloc(sizeof(int));
    *p = 10;
    return 0;
}
```

## 内存锁定

```c
/*
 * int mlock(const void *addr, int len);
 * 锁定addr指向的，长度位len的内存
 * int mlockall(int flags);
 * 锁定当前进程的所有内存
 * int munlock(const void *addr, int len);
 * 解锁内存
 * int munlockall(void);
 * 解锁所有内存
 */

#include <sys/mman.h>
#include <stdio.h>
#include <string.h>

int main(void) {
    int ret;
    char secret[10];

    ret = mlock(secret, strlen(secret));
    if(ret)
        perror("mlock");

    munlockall();
}
```

> int brk(void *end_data_segment);
> 
> 设置program break 位置(堆位置)为指定位置
> 
> 在当前的基础上program break增加increment, 返回program break位置
> void *sbrk(intptr_t increment);

```c
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

int main() {
    void *curr_brk, *tmp_brk=NULL;
    printf("current pid: %d\n", getpid());

    /* 当前Program Break地址 */
    tmp_brk = curr_brk = sbrk(0);
    printf("Program Break Location1: %p\n", curr_brk);

    /* 当前Program Break地址增加4096 */
    sbrk(4096);
    curr_brk = sbrk(0);
    printf("Program Break Location2: %p\n", curr_brk);

    /* 当前Program Break地址增加回到原来位置 */
    brk(tmp_brk);
    curr_brk = sbrk(0);
    printf("Program Break Location3: %p\n", curr_brk);

    return 0;
}
```

> #include <sys/mman.h>
> 
> void *mmap( void *addr,  size_t length,  int prot,  int flags,  int fd, off_t offset );
> 
> int munmap(void *addr, size_t length);

映射共享文件-读

```c
#include <sys/mman.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

int main() {
    int fd = open("/tmp/mmapped.txt", O_RDONLY);
    if (fd == -1) {
        perror("open mapped.txt");
        exit(1);
    }

    struct stat fileInfo;

    if(fstat(fd, &fileInfo) == -1) {
        perror("fstat");
        exit(1);
    }

    printf("File sieze is %d\n", fileInfo.st_size);

    char *map = mmap(NULL, fileInfo.st_size, PROT_READ, MAP_SHARED, fd, 0);
    if(map == MAP_FAILED) {
        close(fd);
        perror("mmap");
        exit(1);
    }

    off_t i;
    for(i=0; i<fileInfo.st_size; i++) {
        printf("Found charter %c at %d\n", map[i], i);
    }

    /* free the mmapped memory */
    if(munmap(map, fileInfo.st_size) == -1) {
        close(fd);
        perror("munmap");
        exit(1);
    }

    close(fd);
    return 0;
}
```

映射共享文件-写

```c
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>

int main() {
    char *text = "hello world\n";
    printf("will write text: %s\n", text);

    int fd = open("/tmp/mmapped.txt", O_RDWR | O_CREAT);

    if(fd == -1) {
        perror("open mmapped");
        exit(1);
    }

    int textsize = strlen(text);
    if(lseek(fd, textsize, SEEK_SET) == -1) {
        close(fd);
        perror("lseek");
        exit(1);
    }

    if(write(fd, "", 1) == -1) {
        close(fd);
        perror("write");
        exit(1);
    }

    char *map = mmap(NULL, textsize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (map == MAP_FAILED) {
        close(fd);
        perror("map");
        exit(1);
    }

    size_t i;
    for(i=0; i < textsize; i++) {
        map[i] = text[i];
    }

    if(msync(map, textsize, MS_SYNC) == -1) {
        perror("msync");
    }

    if(munmap(map, textsize) == -1) {
        close(fd);
        perror("mumap");
        exit(1);
    }
    close(fd);
    return 0;
}
```
