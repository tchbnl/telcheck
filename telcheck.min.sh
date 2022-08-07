telcheck()
{
VERSION="telcheck 0.9 (Updated on 8/6/2022)"
TEXT_BOLD="\e[1m"
TEXT_GREEN="\e[32m"
TEXT_RED="\e[31m"
TEXT_RESET="\e[0m"
MSG_HELP="telcheck is a simple email block checker using telnet.

USAGE: telcheck [-b]
-b --source [IP]    Specify the IP to run the check against.
-h --help           Show this message and exit.
-s --battle         Experimental space battle simulator.
-v --version        Show version information and exit.

Note: Do not abuse this script! Frequent checks can make things worse. Run
once and collect the information. Get delisted. That's it."
HOSTS=("Aol.com, mx-aol.mail.gm0.yahoodns.net"
"Att.net, al-ip4-mx-vip1.prodigy.net"
"Comcast.net, mx1a1.comcast.net"
"Cox.net, cxr.mx.a.cloudfilter.net"
"Earthlink.net, mx01.oxsus-vadesecure.net"
"Fastmail.com, in1-smtp.messagingengine.com"
"Gmail.com, gmail-smtp-in.l.google.com"
"Hotmail.com, hotmail-com.olc.protection.outlook.com"
"Optonline.com, mx.mx-altice.prod.cloud.synchronoss.net"
"Outlook.com, outlook-com.olc.protection.outlook.com"
"Verizon.net, mx-aol.mail.gm0.yahoodns.net"
"Yahoo.com, mta5.am0.yahoodns.net")
while [[ "$#" -gt 0 ]]; do
case "$1" in
-b|--source)
SOURCE_ADDR="$2"
shift
shift
;;
-h|--help)
echo "${MSG_HELP}"
return
;;
-s|--battle)
SOURCE_ADDR="$2"
shift
shift
;;
-v|--version)
echo "${VERSION}"
return
;;
-*|--*)
echo "Unknown option $1"
echo "${MSG_HELP}"
return
;;
*)
echo "Unknown option $1"
echo "${MSG_HELP}"
return
;;
esac
done
if [[ -v SOURCE_ADDR ]]; then
if { echo "quit"; sleep 1.5; } \
| telnet -b "${SOURCE_ADDR}" 127.0.0.1 25 2>&1 \
| grep -Eiq "couldn't bind to|cannot assign|couldn't get|could not resolve|invalid argument"; then
echo "Specified IP is invalid or not available. Aborting attempt.";
unset SOURCE_ADDR
return
fi
fi
if [[ -x /usr/local/cpanel/bin/whmapi1 ]]; then
if whmapi1 listips | sed "/$(hostname -i)/d" | grep -iq "public_ip:"; then
echo -e "${TEXT_BOLD}Found one or more dedicated IPs.${TEXT_RESET} Use '-b [IP]' to re-run against them:"
echo -e "$(whmapi1 listips | sed "/$(hostname -i)/d" | grep -i "public_ip:" \
| awk '{print "* "$2}')\n"
fi
fi
if [[ -v SOURCE_ADDR ]]; then
echo -e "${TEXT_BOLD}Checking ${SOURCE_ADDR}...${TEXT_RESET}\n"; else
echo -e "${TEXT_BOLD}Checking $(hostname -i)...${TEXT_RESET}\n"
fi
for HOST in "${HOSTS[@]}"; do
if [[ "${HOST}" == "Outlook"* ]]; then
if [[ -n "${HOTMAIL_RESPONSE}" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RESET}"; else
RESULT="${TEXT_GREEN}OK${TEXT_RESET}"
fi
echo -e "${TEXT_BOLD}* $(echo "$HOST" | awk -F "," '{print $1}') [$RESULT${TEXT_BOLD}]${TEXT_RESET}"
if [[ -n "${HOTMAIL_RESPONSE}" ]]; then
echo "🚫 ${HOTMAIL_RESPONSE}"
fi
continue
fi
if [[ "${HOST}" == "Verizon"* || "${HOST}" == "Yahoo"* ]]; then
if [[ -n "${AOL_RESPONSE}" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RESET}"; else
RESULT="${TEXT_GREEN}OK${TEXT_RESET}"
fi
echo -e "${TEXT_BOLD}* $(echo "$HOST" | awk -F "," '{print $1}') [$RESULT${TEXT_BOLD}]${TEXT_RESET}"
if [[ -n "${AOL_RESPONSE}" ]]; then
echo "🚫 ${AOL_RESPONSE}"
fi
continue
fi
check_host() {
{ sleep 1.5; echo "ehlo $(hostname)"; sleep 1.5; echo "mail from: <root@$(hostname)>"; sleep 1.5; echo "quit"; sleep 1.5; } \
| telnet ${SOURCE_ADDR:+"-b" "${SOURCE_ADDR}"} "$(echo "${HOST}" | awk '{print $2}')" 25 2>&1
}
RESPONSE="$(check_host \
| grep -Ei "block|blacklist|not allowed|banned|denied|rejected|ivmsip|invaluement|sorbs|spamcop|spamhaus")"
if [[ -n "${RESPONSE}" ]]; then
IS_BLOCKED='true'
RESULT="${TEXT_RED}FAIL${TEXT_RESET}"; else
RESULT="${TEXT_GREEN}OK${TEXT_RESET}"
fi
echo -e "${TEXT_BOLD}* $(echo "${HOST}" | awk -F "," '{print $1}') [${RESULT}${TEXT_BOLD}]${TEXT_RESET}"
if [[ -n "${RESPONSE}" ]]; then
echo "🚫 ${RESPONSE})"
fi
if [[ "${HOST}" == "Aol"* ]]; then
AOL_RESPONSE="${RESPONSE}"
fi
if [[ "${HOST}" == "Hotmail"* ]]; then
HOTMAIL_RESPONSE="${RESPONSE}"
fi
done
if [[ -v IS_BLOCKED ]]; then
echo -e "\nBlock(s) detected. Follow the steps in the above output(s) to delist."
unset IS_BLOCKED; else
echo -e "\nAll clear! No blocks detected."
fi
if [[ -v SOURCE_ADDR ]]; then
unset SOURCE_ADDR
fi
}
