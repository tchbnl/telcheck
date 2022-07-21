# telcheck
telcheck is a simple Bash script that uses telnet to check for blocks with various email providers. It currently checks:

* AOL*
* ATT
* Comcast
* Cox
* EarthLink
* Fastmail
* Gmail
* Hotmail**
* Optimum
* Outlook**
* Verizon*
* Yahoo*

*\* These providers are the same/use the same infrastructure*

*\*\* Same here*

Gmail and Fastmail _should_ work, but I've never run them against a known-blocked server.

## minicheck
minicheck is telcheck without the need to download and execute the script. It's just the Bash code reworked to wrap it in `telcheck()` between brackets and stripped of all comments and spacing to make it as compact as possible. Useful to use once on a server and never again.

If there are problems copying and pasting the whole code into the shell, try doing it half at a time. Windows Terminal seems to be problematic.

I offer no warranty for this code and what it might do etc. etc. Use this responsibly. Frequent checks or suspicious activity can lead to blocks with email providers. I recommend to run this _once_ and save the results. Delist what's listed. That's it.
