# Beep

- victim
  - 10.10.10.7
- local
  - 10.10.14.19

---

## 扫描分析

端口很多，看来rabbit hole不少

简单分析

> 根据题解，主要目标还是Web，第一次做的时候莫名卡死无法访问Web严重影响了做题，可能是nmap把它扫爆了？

- 22

  - ssh,一般问题不大
- [ ] 25

  - smtp,留待分析
- 80
  - 直接302跳转到https，应该问题不大
- [ ] 443
  - 可访问，**重点分析**
- [ ] 110
  - pop3,留待分析
- 111
  - rpcbind，一般没问题
- [ ] 143
  - imap，留待分析
- 879
  - RPC，一般没问题
- [ ] 993
  - Cyrus imapd，留待分析
- [ ] 995
  - Cyrus pop3d，留待分析
- [ ] 3306
  - MySQL (unauthorized)，重点关注一下
- [ ] 4190
  - Cyrus timsieved 2.3.7-Invoca-RPM-2.3.7-7.el5_6.4 (included w/cyrus imap)
  - 留待分析
- 4445
  - 一个无法辨识的端口，先不管了
- [x] 4559
  - HylaFAX 4.3.10
  - EDB显示版本较新，没有EXP
- [ ] 5038
  - Asterisk Call Manager 1.1
  - 没什么想法，也没找到合适的EXP，稍后
- [x] 10000
  - MiniServ 1.570 (Webmin httpd)

根据443.note的结果，密码重用，直接登陆ssh，ssh版本太旧

```bash
ssh root@10.10.10.7 -oKexAlgorithms=+diffie-hellman-group1-sha1
```

登陆成功，直接就是root

root.txt

```
d88e006123842106982acce0aaf453f0
```

user.txt

```
aeff3def0c765c2677b94715cffa73ac
```

