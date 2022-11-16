telcheck() {
if [[ "${BASH_VERSINFO[0]}${BASH_VERSINFO[1]}" -lt "42" ]]; then
echo "telcheck requires at least Bash 4.2 to work. Your version is ${BASH_VERSION}."
return
fi
if ! command -v telnet >/dev/null; then
echo "telcheck requires telnet to work. Hence the name 'tel(net)check'."
return
fi
unset SOURCE_IP
unset VERBOSE
unset IS_BLOCKED
VERSION="telcheck 0.9 R2 (Updated on 11/12/2022)"
TEXT_BOLD="\e[1m"
TEXT_RESET="\e[0m"
HELP_MESSAGE="telcheck is a simple email block checker using telnet.

USAGE: telcheck [-b IP]
  -b --source [IP]        Run check against the given IP address.
  -h --help               Show this message and exit.
  -v --version            Show version information and exit.
  -s --batle              Experimental space battle simulator.
  -V --verbose            Show full host responses regardles of a block.

Note: Do not abuse this script! Frequent checks can make things worse. Run once
and collect the information. Get delisted. That's it."
HOSTS=("Yahoo! (+ AOL and Verizon), mta5.am0.yahoodns.net"
"ATT, al-ip4-mx-vip1.prodigy.net"
"Comcast, mx1a1.comcast.net"
"Cox\U2122, cxr.mx.a.cloudfilter.net"
"EarthLink, mx01.oxsus-vadesecure.net"
"Gmail, gmail-smtp-in.l.google.com"
"Outlook (+ Hotmail), outlook-com.olc.protection.outlook.com")
while [[ "${#}" -gt 0 ]]; do
case "${1}" in
-b|--source|-s|--battle)
if [[ -z "${2}" ]]; then
echo "You must specify an IP address to check with. Use '-b IP'."
return
else
SOURCE_IP="${2}"
shift 2
fi
;;
-h|--help)
echo "${HELP_MESSAGE}"
return
;;
-v|--version)
echo "${VERSION}"
return
;;
-V|--verbose)
VERBOSE="Yes"
shift 1
;;
-*)
echo -e "Not sure what '${1}' is supposed to be.\n"
echo "${HELP_MESSAGE}"
return
;;
esac
done
if (sleep 1; echo "QUIT") | telnet ${SOURCE_IP:+-b ${SOURCE_IP} }127.0.0.1 25 2>&1 \
| grep -Eiq "unable to connect|can't assign|cannot assign|nodename nor servname provided|couldn't get address|could not get address|name or service not known"; then
echo -e "${TEXT_BOLD}Error:${TEXT_RESET} IP address is invalid or not" \
"available. telcheck requires a public IP address assigned to the server in order to work.\n"
echo "IP: ${SOURCE_IP:-"$(hostname -i)"}"
return
fi
if [[ -x /usr/local/cpanel/bin/whmapi1 ]]; then
if whmapi1 listips | sed '/'"$(hostname -i)"'/d' | grep -iq "public_ip:"; then
echo -e "${TEXT_BOLD}Found one or more additional IP addresses:${TEXT_RESET}"
whmapi1 listips | sed '/'"$(hostname -i)"'/d' | grep -i "public_ip:" \
| awk -F ': ' '{print "* " $2}'
echo -e "You can check a different IP address with '-b IP'.\n"
fi
fi
WAIT_TEXT=("Reticulating splines"
"Enumerating beagles"
"Rotating hedges"
"Formulating ruses")
echo -e "${TEXT_BOLD}${SOURCE_IP:-"$(hostname -i)"}${TEXT_RESET}"
echo -e "Please wait. ${WAIT_TEXT[$((RANDOM % ${#WAIT_TEXT[@]}))]}...\n"
BAD_WORDS="banned|blacklist|blacklisted|block|blocklisted|denied|dnsbl|dnsrbl|found on one or more|invaluement|ivmsip|is on a|not allowed|rbl|rejected|sorbs|spamcop|spamhaus"
telcheck() {
(sleep 1.5; echo "EHLO $(hostname)"; sleep 1.5; echo "MAIL FROM: <root@$(hostname)>"; sleep 1.5; echo "QUIT") \
| telnet ${SOURCE_IP:+-b ${SOURCE_IP} }"${*}" 25 2>&1
}
for HOST in "${HOSTS[@]}"; do
echo -e "${TEXT_BOLD}$(echo "${HOST}" | awk -F ',' '{print $1}')${TEXT_RESET}"
TRESULT="$(telcheck "$(echo "${HOST}" | awk -F ', ' '{print $2}')")"
if echo "${TRESULT}" | grep -Eiq "${BAD_WORDS}"; then
echo -e "\U26D4 Fail"
IS_BLOCKED="Yes"
if [[ ! -v VERBOSE ]]; then
echo "${TRESULT}" | grep -Ei "${BAD_WORDS}"
fi
else
echo -e "\U1F44D Pass"
fi
if [[ -v VERBOSE ]]; then
echo "${TRESULT}"
fi
echo
done
if [[ -v IS_BLOCKED ]]; then
echo "One or more blocks detected! Follow the instructions from the output above to delist."
else
echo "All clear! No blocks detected."
fi
}
