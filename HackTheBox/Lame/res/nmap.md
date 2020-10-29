## Heavy Scan

```bash
sudo nmap 10.10.10.3 -p- -A
```

```
PORT     STATE SERVICE     VERSION
21/tcp   open  ftp         vsftpd 2.3.4
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to 10.10.14.9
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      vsFTPd 2.3.4 - secure, fast, stable
|_End of status
22/tcp   open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
| ssh-hostkey: 
|   1024 60:0f:cf:e1:c0:5f:6a:74:d6:90:24:fa:c4:d5:6c:cd (DSA)
|_  2048 56:56:24:0f:21:1d:de:a7:2b:ae:61:b1:24:3d:e8:f3 (RSA)
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 3.0.20-Debian (workgroup: WORKGROUP)
3632/tcp open  distccd     distccd v1 ((GNU) 4.2.4 (Ubuntu 4.2.4-1ubuntu4))
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: broadband router|remote management|WAP|printer|general purpose
Running (JUST GUESSING): Arris embedded (92%), Dell embedded (92%), Linksys embedded (92%), Tranzeo embedded (92%), Xerox embedded (92%), Linux 2.4.X|2.6.X (92%), Dell iDRAC 6 (92%), Supermicro embedded (92%)
OS CPE: cpe:/h:dell:remote_access_card:6 cpe:/h:linksys:wet54gs5 cpe:/h:tranzeo:tr-cpq-19f cpe:/h:xerox:workcentre_pro_265 cpe:/o:linux:linux_kernel:2.4 cpe:/o:linux:linux_kernel:2.6 cpe:/o:dell:idrac6_firmware cpe:/o:supermicro:intelligent_platform_management_firmware
Aggressive OS guesses: Arris TG862G/CT cable modem (92%), Dell Integrated Remote Access Controller (iDRAC6) (92%), Linksys WET54GS5 WAP, Tranzeo TR-CPQ-19f WAP, or Xerox WorkCentre Pro 265 printer (92%), Linux 2.4.21 - 2.4.31 (likely embedded) (92%), Linux 2.4.27 (92%), Linux 2.6.27 - 2.6.28 (92%), Linux 2.6.8 - 2.6.30 (92%), Dell iDRAC 6 remote access controller (Linux 2.6) (92%), Supermicro IPMI BMC (Linux 2.6.24) (92%), Raritan Dominion PX DPXR20-20L power control unit (92%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
              
Host script results:                 
|_clock-skew: mean: 2h00m09s, deviation: 2h49m46s, median: 6s                      
| smb-os-discovery:                  
|   OS: Unix (Samba 3.0.20-Debian)   
|   Computer name: lame              
|   NetBIOS computer name:           
|   Domain name: hackthebox.gr       
|   FQDN: lame.hackthebox.gr         
|_  System time: 2020-10-17T11:00:12-04:00                  
| smb-security-mode:|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
|_smb2-time: Protocol negotiation failed (SMB2)
```

