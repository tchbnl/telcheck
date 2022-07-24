# telcheck
![telcheck](https://user-images.githubusercontent.com/86271004/180286893-1cd273ea-c113-48ba-9fbd-fc777d318d14.png)
![telcheck](https://user-images.githubusercontent.com/86271004/180287603-c50b7443-8037-4510-a42b-44e903a14d23.png)

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

The additional IP detection uses the cPanel API, so will only work on cPanel servers. You can still use the `-b` option manually to specify an IP to check with. As long as the IP is on the server, it should work. The script does a test telnet connection against 127.0.0.1 to make sure the IP can bind.

## minicheck
minicheck is telcheck without the need to download and execute the script. It's just the Bash code reworked to wrap it in `telcheck()` between brackets and stripped of all comments and spacing to make it as compact as possible. Useful to use once on a server and never again.

If there are problems copying and pasting the whole code into the shell, try doing it half at a time. Windows Terminal seems to be problematic.

I offer no warranty for this code and what it might do etc. etc. Use this responsibly. Frequent checks or suspicious activity can lead to blocks with email providers. I recommend to run this _once_ and save the results. Delist what's listed. That's it.
