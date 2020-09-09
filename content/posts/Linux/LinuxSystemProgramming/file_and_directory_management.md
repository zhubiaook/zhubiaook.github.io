---
title: "文件和目录管理"
date: 2020-09-07
hero: /assets/images/default-hero.jpg
menu:
  sidebar:
    name: "file_and_directory_management"
    identifier: "Linux.LinuxSystemProgramming.file_and_directory_management.md"
    parent: Linux.LinuxSystemProgramming
---

# 文件及元数据

## 基本属性

> stat结构体

```c
struct stat {
    dev_t st_dev;     // ID of device containing file
    ino_t st_ino;     // inode number
    mode_t st_mode;   // permissions
    nlink_t st_nlink; // number of hard link
    uid_t st_uid;     // user ID of owner
    gid_t st_gid;     // group ID of owner
    dev_t st_rdev;    // device ID 
    off_t st_size;    // total size in bytes
    blksize_t st_blksize;  // blocksize for filesystem I/O
    blkcnt_t st_blocks;    // number of blocks allocated
    time_t st_atime;       // last access time
    time_t st_mtime;       // last modification time
    time_t st_ctime;       // last status change time
}
```

> `int stat(const char *path, struct stat *buf);`
> 
> `int fstat(int fd, struct stat *buf);`
> 
> `int lstat(const char *path, struct stat *buf);`

```c
#include <sys/stat.h>
#include <stdio.h>

int main(void) {
    char *path = "/opt/c/1.txt";
    struct stat sb;
    int ret;

    ret = stat(path, &sb);
    if(ret == -1)
        perror("stat");

    printf("uid: %d", sb.st_uid);
}
```

> `int chmod(const char *path, mode_t mode);`

```c
#include <sys/stat.h>
#include <stdio.h>

int main(void) {
    int ret;

    ret = chmod("/opt/c/1.txt", S_IRUSR | S_IWUSR);
    if(ret == -1)
        perror("chmod");
}
```

> 判断文件属性
> 
> `int access(const char pathname, int mode);`
> 
> mode:
> 
> * F_OK 文件是否存在
> 
> * R_OK 文件是否存在，并可读
> 
> * W_OK 文件是否存在，并可写
> 
> * X_OK 文件是否存在，并可执行

```c
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    char *path = "./test";
    int ret;

    ret = access(path, X_OK);
    if(ret == -1)
        perror("error access");

    printf("%d", ret);
}
```

## 扩展属性

```c
/*
 * int getxattr(char *path, char *key, void *value, int size);
 * int setxattr(char *path, char *key, void *value, int size, int flags);
 * int listxattr(char *path, char *list, int size);
 * int removexattr(char *path, char *key);
 */
```

# 目录

> `char *getcwd(char *buf, int size);`
> 
> 获取当前工作目录

```c
#include <unistd.h>
#include <stdio.h>

int main(void) {
    char cwd[100];
    if(!getcwd(cwd, 100)) {
        perror("getcwd");
        return 1;
    }

    printf("cwd: %s\n", cwd);
}
```

> `int chdir(char *path);`
> 
> 改变当前工作目录

```c
#include <unistd.h>
#include <stdio.h>

int main(void) {
    int ret;
    ret = chdir("/data/jupyter/notebook/jupyter/C/Linux_system_programming");
    if(ret == -1) 
        perror("chdir");
}
```

> `DIR *opendir(char *name);`
> 
> `struct dirent *readdir(Dir *dir);`
> 
> `int closdir(DIR *dir);`

```c
#include <sys/types.h>
#include <dirent.h>
#include <stdio.h>

int main(void) {
    DIR *dir;
    struct dirent *entry;

    dir = opendir("/data/jupyter/notebook/jupyter/C");
    while((entry = readdir(dir)) != NULL) {
        printf("%s\n", entry->d_name);
    }
    closedir(dir);
}
```

# 链接

## 硬链接

```c
/*
 * int link(char *oldpath, char *newpath);
 * int unlink(*path);
 * int remove(*path);
 */

 #include <unistd.h>
 #include <stdio.h>

 int main() {
     int ret;
     ret = link("/opt/c/1.txt", "/opt/c/3.txt");
     if(ret)
         perror("link");
 }
```

## 符号链接

```c
/*
 * int symlink(char *oldpath, char *newpath);
 */

 #include <unistd.h>
 #include <stdio.h>

 int main() {
     int ret;
     ret = symlink("/opt/c/1.txt", "/opt/c/4.txt");
     if(ret)
         perror("symlink");
 }
```

# 监视文件事件
