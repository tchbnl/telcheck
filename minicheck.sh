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
MSG_VERSION="telcheck 0.6 (Updated on 7/21/2022)"
MSG_IPS="${TEXT_BLD}Found one or more dedicated IPs.${TEXT_RST} Use '-b [IP]' to re-run against them:"
MSG_BLOCK="Block(s) detected. Follow the steps in the above output(s) to delist."
MSG_CLEAR="All clear! No blocks detected."
MSG_BAD_SOURCE="Specified IP is invalid or not available. Aborting attempt."
COMMANDS="sleep 1.5; echo \"ehlo $(hostname)\"; sleep 1.5; echo \"mail from: <root@$(hostname)>\"; sleep 1.5; echo \"quit\"; sleep 1.5;"
HOST_AOL="mx-aol.mail.gm0.yahoodns.net"
HOST_ATT="al-ip4-mx-vip1.prodigy.net"
HOST_COMCAST="mx1a1.comcast.net"
HOST_COX="cxr.mx.a.cloudfilter.net"
HOST_EARTHLINK="mx01.oxsus-vadesecure.net"
HOST_FASTMAIL="in1-smtp.messagingengine.com"
HOST_GMAIL="gmail-smtp-in.l.google.com"
HOST_HOTMAIL="hotmail-com.olc.protection.outlook.com"
HOST_OPTIMUM="mx.mx-altice.prod.cloud.synchronoss.net"
HOST_OUTLOOK="outlook-com.olc.protection.outlook.com"
HOST_VERIZON="mx-aol.mail.gm0.yahoodns.net"
HOST_YAHOO="mta5.am0.yahoodns.net"
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
echo "Unknon option $1"
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
testSource="$({ echo "quit"; sleep 2; } | telnet $SOURCE_ADDR 127.0.0.1 25 2>&1)"
RESPONSE="$(echo "$testSource" | grep -iE "couldn't bind to|cannot assign|couldn't get|could not resolve|invalid argument")"
if [[ $RESPONSE != "" ]]; then
echo "$MSG_BAD_SOURCE"
unset SOURCE_ADDR
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
checkAol="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_AOL 25 2>&1)"
RESPONSE="$(echo "$checkAol" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Aol.com [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
checkAtt="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_ATT 25 2>&1)"
RESPONSE="$(echo "$checkAtt" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Att.net [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
checkComcast="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_COMCAST 25 2>&1)"
RESPONSE="$(echo "$checkComcast" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}Comcastic\u21${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Comcast.net [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
checkCox="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_COX 25 2>&1)"
RESPONSE="$(echo "$checkCox" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Cox.net [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
checkEarthlink="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_EARTHLINK 25 2>&1)"
RESPONSE="$(echo "$checkEarthlink" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Earthlink.net [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
checkFastmail="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_FASTMAIL 25 2>&1)"
RESPONSE="$(echo "$checkFastmail" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Fastmail.com [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
checkGmail="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_GMAIL 25 2>&1)"
RESPONSE="$(echo "$checkGmail" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Gmail.com [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
checkHotmail="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_HOTMAIL 25 2>&1)"
RESPONSE="$(echo "$checkHotmail" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Hotmail.com [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
checkOptimum="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_OPTIMUM 25 2>&1)"
RESPONSE="$(echo "$checkOptimum" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Optonline.com [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
checkOutlook="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_OUTLOOK 25 2>&1)"
RESPONSE="$(echo "$checkOutlook" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Outlook.com [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
checkVerizon="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_VERIZON 25 2>&1)"
RESPONSE="$(echo "$checkVerizon" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}OK${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Verizon.net [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
checkYahoo="$(eval { $COMMANDS } | telnet $SOURCE_ADDR $HOST_YAHOO 25 2>&1)"
RESPONSE="$(echo "$checkYahoo" | grep -iE "$FILTER_LIST")"
if [[ $RESPONSE != "" ]]; then
IS_BLOCKED="true"
RESULT="${TEXT_RED}FAIL${TEXT_RST}"; else
RESULT="${TEXT_GRN}Yahoo\u21${TEXT_RST}"
fi
echo -e "${TEXT_BLD}* Yahoo.com [$RESULT${TEXT_BLD}]${TEXT_RST}"
if [[ $RESPONSE != "" ]]; then
echo -e "\u2937 $(echo "$RESPONSE" | grep -iE "$FILTER_LIST")"
fi
if [[ $IS_BLOCKED = "true" ]]; then
echo -e "\n$MSG_BLOCK"; else
echo -e "\n$MSG_CLEAR"
fi
if [[ $SOURCE_ADDR || $IS_BLOCKED ]]; then
unset SOURCE_ADDR; unset IS_BLOCKED
fi
}
