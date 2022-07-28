# telcheck
![telcheck](https://user-images.githubusercontent.com/86271004/181644616-336a469d-64a2-4c88-b966-46edd271f3c0.png)

telcheck is a simple Bash script that uses telnet to check for blocks with various email providers. It currently checks:

| Provider  | Confirmed Works |
| :-------- | :-------------- |
| AOL       | Yes             |
| ATT       | Yes             |
| Comcast   | Yes             |
| Cox       | Yes             |
| EarthLink | Yes             |
| Fastmail  | No              |
| Gmail     | No              |
| Hotmail   | Yes             |
| Optimum   | Yes             |
| Outlook   | Yes             |
| Verizon   | Yes             |
| Yahoo     | Yes             |

Gmail and Fastmail _should_ work, but I've never run them against a known-blocked server.

The additional IP detection uses the cPanel API, so it'll only work on cPanel servers. You can still use the `-b` option manually to specify an IP to check with. As long as the IP is on the server, it should work. The script does a test connection against 127.0.0.1 to make sure the IP can bind.

As of v0.8, the Outlook, Verizon, and Yahoo checks are skipped and use the results from AOL or Hotmail to avoid unnecessary lookups against providers that use the same infrastructure.

The current version is **v0.8**. It was last updated on **07/28/2022**. You can always check your current version with `-v` or `--version`.

## minicheck
minicheck is a compressed version of telcheck that can be run directly from the shell. Just copy and paste the code into the active shell session and run `telcheck` like normal. It's the exact same code without the extra spaces and comments. As always, make sure you read and understand the code you run from strangers on the Internet.

I offer no warranty for this software and what it might do etc. You are responsible for the reputation of your mail server and what runs on it.
