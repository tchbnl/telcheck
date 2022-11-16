```
# telcheck -h
telcheck is a simple email block checker using telnet.

USAGE: telcheck [-b IP]
  -b --source [IP]        Run check against the given IP address.
  -h --help               Show this message and exit.
  -v --version            Show version information and exit.
  -s --batle              Experimental space battle simulator.
  -V --verbose            Show full host responses regardles of a block.

Note: Do not abuse this script! Frequent checks can make things worse. Run once
and collect the information. Get delisted. That's it.
```

* Yahoo/AOL/Verizon
* ATT
* Comcast
* Cox
* EarthLink
* Gmail
* Outlook/Hotmail

Gmail _should_ work, but I haven't been able to check it against a blocked IP. I've confirmed all other hosts do work.

Support is available to check different IP addresses, as well as a verbose mode to view the entire telnet output for troubleshooting or extra information.

The current version is **v0.9 R2 (Updated on 11/9/2022)**. You can check the downloaded version with `-v` or `--version`. R2 is a rewrite of the original telcheck code and includes overall "better" code quality, a redesigned output, and a verbose mode. R1 is still available and includes additional checks for Fastmail and Optimum. You can find it in the 'classic' branch. A minified version that can work on CentOS 6 is also available, albeit without support (I needed it one time).

A minified version without comments and extra spaces is available as telcheck.min.sh. This version is designed to be pasted directly into an open Bash shell and run like normal.

telcheck is released under the venerable DWYWIDC License. Do What You Want; I Don't Care. Just remember to credit me, and stop spamming so much that this script is needed. Check LICENSE for the details.

I offer no warranty for this script and what it might do. You are ultimately the one responsible for the reputation of your mail server and what runs on it.

## A note on Windows Terminal and telcheck.min
For some reason Windows Terminal has a hard time handling pasted text longer than about 100 lines. I recommend splitting the code up into two pastes in case of problems.
