```bash
gobuster dir -u http://192.168.159.129/tiki/ \
  -w /usr/share/seclists/Discovery/Web-Content/common.txt \
  -s '200,204,301,302,307,403,500'
```

```
/.hta (Status: 403)
/.htaccess (Status: 403)
/.htpasswd (Status: 403)
/admin (Status: 301)
/README (Status: 200)
/db (Status: 301)
/doc (Status: 301)
/dump (Status: 301)
/img (Status: 301)
/installer (Status: 301)
/lang (Status: 301)
/lib (Status: 301)
/index.php (Status: 302)
/lists (Status: 301)
/modules (Status: 301)
/robots.txt (Status: 200)
/storage (Status: 301)
/temp (Status: 301)
/templates (Status: 301)
/themes (Status: 301)
/vendor (Status: 301)
/xmlrpc.php (Status: 200)
```

