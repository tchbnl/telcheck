A simple script to check for email blocks with telnet. That's it.

```
[root@cwp ~]# telcheck
Checking 5.161.254.101...

AOL & Yahoo!
Trying 98.136.96.92...
Connected to mx-aol.mail.gm0.yahoodns.net.
Escape character is '^]'.
220 mtaproxy121.aol.mail.ne1.yahoo.com ESMTP ready
250-mtaproxy121.aol.mail.ne1.yahoo.com
250-PIPELINING
250-SIZE 41943040
250-8BITMIME
250 STARTTLS
250 sender <root@cwp.tchbnl.net> ok
Connection closed by foreign host.

AT&T
Trying 144.160.235.143...
Connected to al-ip4-mx-vip1.prodigy.net.
Escape character is '^]'.
220 alph731.prodigy.net ESMTP Sendmail Inbound 8.15.2/8.15.2; Sun, 9 Mar 2025 15:25:02 -0400
250-alph731.prodigy.net Hello static.101.254.161.5.clients.your-server.de [5.161.254.101], pleased to meet you
250 ENHANCEDSTATUSCODES
553 5.3.0 alph731 DNSBL:RBL 521< 5.161.254.101 >_is_blocked.For assistance forward this error to abuse_rbl@abuse-att.net
Connection closed by foreign host.

Comcast
Trying 96.103.145.162...
Connected to mx1.mxge.comcast.net.
Escape character is '^]'.
220 resimta-a2p-650779.sys.comcast.net resimta-a2p-650779.sys.comcast.net ESMTP server ready
250-resimta-a2p-650779.sys.comcast.net hello [5.161.254.101], pleased to meet you
250-HELP
250-SIZE 36700160
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-STARTTLS
250 OK
250 2.1.0 <root@cwp.tchbnl.net> sender ok
Connection closed by foreign host.

Gmail (Unreliable)
Trying 142.251.179.27...
Connected to gmail-smtp-in.l.google.com.
Escape character is '^]'.
220 mx.google.com ESMTP af79cd13be357-7c548b7c7desi241161485a.388 - gsmtp
250-mx.google.com at your service, [5.161.254.101]
250-SIZE 157286400
250-8BITMIME
250-STARTTLS
250-ENHANCEDSTATUSCODES
250-PIPELINING
250-CHUNKING
250 SMTPUTF8
250 2.1.0 OK af79cd13be357-7c548b7c7desi241161485a.388 - gsmtp
Connection closed by foreign host.

Outlook & Hotmail
Trying 52.101.73.17...
Connected to outlook-com.olc.protection.outlook.com.
Escape character is '^]'.
220 AMS0EPF0000019A.mail.protection.outlook.com Microsoft ESMTP MAIL Service ready at Sun, 9 Mar 2025 19:25:28 +0000 [08DD59CA63652EED]
250-AMS0EPF0000019A.mail.protection.outlook.com Hello [5.161.254.101]
250-SIZE 49283072
250-PIPELINING
250-DSN
250-ENHANCEDSTATUSCODES
250-STARTTLS
250-8BITMIME
250-BINARYMIME
250-CHUNKING
250 SMTPUTF8
250 2.1.0 Sender OK
Connection closed by foreign host.
```

A future release will hide the output (unless --verbose is used) and show simple a PASS/FAIL (with message).

**Wasn't there another telcheck?**
No. It never existed. You're mistaken. Seek help.
