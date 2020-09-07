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

```c
/*
 * int stat(const char *path, struct stat *buf);
     获取文件信息
     st_dev
     st_ino
     st_mode
     st_nlink
     st_uid
     st_gid
     st_rdev
     st_size
     st_blksize
     st_blocks
     st_atime
     st_mtime
     st_ctime
 */

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

    uid: 1000

```c
/*
 * int chmod(const char *path, mode_t mode);
 * 修改文件权限
 */

#include <sys/stat.h>
#include <stdio.h>

int main(void) {
    int ret;

    ret = chmod("/opt/c/1.txt", S_IRUSR | S_IWUSR);
    if(ret == -1)
        perror("chmod");
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

    /tmp/tmpmvfzmx2j.out: /tmp/tmpjaya540_.out: undefined symbol: main
    [C kernel] Executable exited with code 1

# 目录

```c
/*
 * char *getcwd(char *buf, int size);
 * 获取当前工作目录
 */

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

    cwd: /data/jupyter/notebook/jupyter/C/Linux_system_programming

```c
/*
 * int chdir(char *path);
 * 改变当前工作目录
 */

#include <unistd.h>
#include <stdio.h>

int main(void) {
    int ret;
    ret = chdir("/data/jupyter/notebook/jupyter/C/Linux_system_programming");
    if(ret == -1) 
        perror("chdir");
}
```

```c
/*
 * DIR *opendir(char *name);
 * struct dirent *readdir(Dir *dir);
 * int closdir(DIR *dir);
 */

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

    程序编译_链接.ipynb
    Linux_system_programming
    C语言入门
    .
    ..
    .ipynb_checkpoints

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

    link: File exists

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

    /tmp/tmp0bt5x683.c: In function ‘main’:
    /tmp/tmp0bt5x683.c:9:5: warning: implicit declaration of function ‘symlink’ [-Wimplicit-function-declaration]
         symlink("/opt/c/1.txt", "/opt/c/4.txt");
         ^

# 监视文件事件

```c

```

```c

```
