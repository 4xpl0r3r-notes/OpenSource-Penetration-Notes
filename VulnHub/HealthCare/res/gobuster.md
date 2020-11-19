```bash
gobuster dir -u http://192.168.159.131/ \
  -w /usr/share/seclists/Discovery/Web-Content/common.txt \
  -s '200,204,301,302,307,403,500' -e
```

找不到啥，更换字典

```bash
gobuster dir -u http://192.168.159.131/ \
  -w /usr/share/wordlists/seclists/Discovery/Web-Content/directory-list-2.3-big.txt \
  -s '200,204,301,302,307,403,500' -e
```

```
http://192.168.159.131/index (Status: 200)
http://192.168.159.131/images (Status: 301)
http://192.168.159.131/css (Status: 301)
http://192.168.159.131/js (Status: 301)
http://192.168.159.131/vendor (Status: 301)
http://192.168.159.131/favicon (Status: 200)
http://192.168.159.131/robots (Status: 200)
http://192.168.159.131/fonts (Status: 301)
http://192.168.159.131/gitweb (Status: 301)
http://192.168.159.131/phpMyAdmin (Status: 403)
http://192.168.159.131/server-status (Status: 403)
http://192.168.159.131/server-info (Status: 403)
http://192.168.159.131/openemr (Status: 301)
```

找到这个主要的`openemr`