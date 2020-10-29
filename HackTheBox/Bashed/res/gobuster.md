```bash
gobuster dir -u http://10.10.10.68/ \
  -w /usr/share/seclists/Discovery/Web-Content/common.txt \
  -s '200,204,301,302,307,403,500' -e -x php > gobuster.txt
```

```
http://10.10.10.68/.hta (Status: 403)
http://10.10.10.68/.hta.php (Status: 403)
http://10.10.10.68/.htaccess (Status: 403)
http://10.10.10.68/.htaccess.php (Status: 403)
http://10.10.10.68/.htpasswd (Status: 403)
http://10.10.10.68/.htpasswd.php (Status: 403)
http://10.10.10.68/config.php (Status: 200)
http://10.10.10.68/css (Status: 301)
http://10.10.10.68/dev (Status: 301)
http://10.10.10.68/fonts (Status: 301)
http://10.10.10.68/images (Status: 301)
http://10.10.10.68/index.html (Status: 200)
http://10.10.10.68/js (Status: 301)
http://10.10.10.68/php (Status: 301)
http://10.10.10.68/server-status (Status: 403)
http://10.10.10.68/uploads (Status: 301)
```

```bash
gobuster dir -u http://10.10.10.68/uploads/ \
  -w /usr/share/wordlists/dirb/small.txt \
  -s '200,204,301,302,307,403,500' -e -x php > gobuster.txt
```

