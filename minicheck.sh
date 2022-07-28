telcheck()
{
if [[ $SOURCE_ADDR || $IS_BLOCKED ]]; then
unset SOURCE_ADDR; unset IS_BLOCKED
fi
TEXT_BLD="\e[1m"
TEXT_GRN="\e[32m"
TEXT_RED="\e[31m"
TEXT_RST="\e[0m"
MSG_HELP="telcheck is a simple email block checker using telnet.

USAGE: telcheck [-b]
    -b --source [IP]    Specify the IP to run the check against.
    -h --help           Show this message and exit.
    -s --battle         Experimental space battle simulator.
    -v --version        Show version information and exit.

Note: Do not abuse this script! Frequent checks can make things worse. Run
once and collect the information. Get delisted. That's it."
MSG_VERSION="telcheck 0.8 (Updated on 7/28/2022)"
MSG_IPS="${TEXT_BLD}Found one or more dedicated IPs.${TEXT_RST} Use '-b [IP]' to re-run against them:"
MSG_BLOCK="Block(s) detected. Follow the steps in the above output(s) to delist."
MSG_CLEAR="All clear! No blocks detected."
MSG_BAD_SOURCE="Specified IP is invalid or not available. Aborting attempt."
COMMANDS="sleep 1.5; echo \"ehlo $(hostname)\"; sleep 1.5; echo \"mail from: <root@$(hostname)>\"; sleep 1.5; echo \"quit\"; sleep 1.5;"
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
FILTER_LIST="block|blacklist|not allowed|banned|denied|rejected|ivmsip|invaluement|sorbs|spamcop|spamhaus"
while [[ $# -gt 0 ]]; do
case $1 in
-b|--source)
SOURCE_ADDR="-b $2"
shift
shift
;;
-h|--help)
echo "$MSG_HELP"
return
;;
-s|--battle)
SOURCE_ADDR="-b $2"
shift
shift
;;
-v|--version)
echo "$MSG_VERSION"
return
;;
-*|--*)
echo "Unknown option $1"
echo "$MSG_HELP"
return
;;
*)
echo "Unknown option $1"
echo "$MSG_HELP"
return
;;
esac
done
if [[ $SOURCE_ADDR ]]; then
testSource="$({ echo "quit"; sleep 1.5; } | telnet $SOURCE_ADDR 127.0.0.1 25 2>&1)"
RESPONSE="$(echo "$testSource" | grep -iE "couldn't bind to|cannot assign|couldn't get|could not resolve|invalid argument")"
if [[ $RESPONSE != "" ]]; then
echo "$MSG_BAD_SOURCE"; unset SOURCE_ADDR
return
fi
fi
if [[ -x /usr/local/cpanel/bin/whmapi1 ]]; then
IP_LIST="$(whmapi1 listips | grep -i "_ip:" | awk '{print $2}')"
if [[ $IP_LIST != "$(hostname -i)" ]]; then
echo -e "$MSG_IPS"
echo -e "$(whmapi1 listips | grep -i "_ip:" | sed "/$(hostname -i)/d" | awk '{print "* "$2}')\n"
fi
fi
if [[ $SOURCE_ADDR ]]; then
echo -e "${TEXT_BLD}Checking $(echo "$SOURCE_ADDR" | awk '{print $2}')...${TEXT_RST}\n"; else
echo -e "${TEXT_BLD}Checking $(hostname -i)...${TEXT_RST}\n"
fi
for HOST in "${HOSTS[@]}"; do
if [[ $HOST = "Outlook"* ]]; then
if [[ $HOTMAIL_RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* $(echo "$HOST" | awk -F "," '{print $1}') [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $HOTMAIL_RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
continue; elif [[ $HOST = "Verizon"* || $HOST = "Yahoo"* ]]; then
if [[ $AOL_RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* $(echo "$HOST" | awk -F "," '{print $1}') [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $AOL_RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
continue
fi
checkHost="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $(echo "$HOST" | awk '{print $2}') 25 2>&1)"
RESPONSE="$(echo "$checkHost" | grep -iE "$FILTER_LIST")"
if [[ $HOST = "Aol"* ]]; then
AOL_RESPONSE="$RESPONSE"; elif [[ $HOST = "Hotmail"* ]]; then
HOTMAIL_RESPONSE="$RESPONSE"
fi
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* $(echo "$HOST" | awk -F "," '{print $1}') [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
done
if [[ $IS_BLOCKED = "true" ]]; then
echo -e "\n$MSG_BLOCK"; else
echo -e "\n$MSG_CLEAR"
fi
if [[ $SOURCE_ADDR || $IS_BLOCKED ]]; then
unset SOURCE_ADDR; unset IS_BLOCKED
fi
}
