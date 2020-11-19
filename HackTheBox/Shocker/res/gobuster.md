```bash
gobuster dir -u http://10.10.10.56/ \
  -w /usr/share/seclists/Discovery/Web-Content/common.txt \
  -s '200,204,301,302,307,403,500' -e > gobuster.txt
```

```
===============================================================
http://10.10.10.56/.hta (Status: 403)
http://10.10.10.56/.htaccess (Status: 403)
http://10.10.10.56/.htpasswd (Status: 403)
http://10.10.10.56/cgi-bin/ (Status: 403)
http://10.10.10.56/index.html (Status: 200)
http://10.10.10.56/server-status (Status: 403)
===============================================================
```

```bash
gobuster dir -u http://10.10.10.56/cgi-bin/   -w /usr/share/wordlists/dirb/small.txt   -s '200,204,301,302,307,403,500' -x cgi,sh,pl,py -e
```

```
http://10.10.10.56/cgi-bin/user.sh
```

