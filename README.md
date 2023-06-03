```
# telcheck -h
telcheck is a simple email block checker using telnet.

USAGE: telcheck [-b IP]
  -b --source [IP]        Run check against the given IP address.
  -h --help               Show this message and exit.
  -v --version            Show version information and exit.
  -s --battle             Experimental space battle simulator.
  -V --verbose            Show full host responses regardles of a block.

Note: Do not abuse this script! Frequent checks can make things worse. Run once
and collect the information. Get delisted. That's it.
```

```
root@myvps86753 [~]# telcheck
5.121.125.25
Please wait. Enumerating beagles...

Yahoo! (+ AOL and Verizon)
👍 Pass

ATT
👍 Pass

Comcast
👍 Pass

Cox™
👍 Pass

EarthLink
👍 Pass

Gmail
👍 Pass

Outlook (+ Hotmail)
👍 Pass

All clear! No blocks detected.
```

telcheck currently checks against these email providers:

* Yahoo/AOL/Verizon
* ATT
* Comcast
* Cox
* EarthLink
* Gmail
* Outlook/Hotmail

Gmail _should_ work, but I haven't been able to check it against a blocked IP (it's surprisingly hard to ask for dirty IPs from hosts ¯\\\_(ツ)\_/¯). I've confirmed all other hosts do work.

Support is available to check different IP addresses, as well as a verbose mode to view the entire telnet output for troubleshooting or extra information.

The current version is **v0.9 R2 (Updated on 6/3/2023)**. You can check the downloaded version with `-v` or `--version`. R2 is a major rewrite of the original with code "improvements" and a "nicer" interface.

A minified version without comments and extra spaces is available as telcheck.min.sh. This version is designed to be pasted directly into an open Bash shell and run like normal. There's also a minified version that should work on systems with older Bash versions like CentOS 6 (I only maintain this because I need it sometimes).

I offer no warranty for this script and what it might do. You are ultimately the one responsible for the reputation of your mail server and what runs on it.
