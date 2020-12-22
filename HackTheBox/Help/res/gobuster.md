```bash
gobuster dir -u http://10.129.1.103/ -w "/usr/share/wordlists/seclists/Discovery/Web-Content/common.txt"
```

```
/.hta (Status: 403)
/.htaccess (Status: 403)
/.htpasswd (Status: 403)
/index.html (Status: 200)
/javascript (Status: 301)
/server-status (Status: 403)
/support (Status: 301)
```

