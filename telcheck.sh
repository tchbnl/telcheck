#!/bin/bash
# telcheck: Check for email blocks with telnet
# Nathan Paton <nathanpat@inmotionhosting.com>
# v0.9 (Updated on 10/21/2022)

# Check the Bash version. telcheck requires at least 4.2 to work.
if [[ "${BASH_VERSINFO[0]}${BASH_VERSINFO[1]}" -lt "42" ]]; then
  echo "telcheck requires at least Bash 4.2 to work. Your version is ${BASH_VERSION}."
  exit
fi

# Version number is latest change date
VERSION="telcheck 0.9 (Updated on 10/21/2022)"

# Text formatting options
TEXT_BOLD="\e[1m"
TEXT_GREEN="\e[32m"
TEXT_RED="\e[31m"
TEXT_RESET="\e[0m"

# Help message when -h or an unknown option is passed
MSG_HELP="telcheck is a simple email block checker using telnet.

USAGE: telcheck [-b]
    -b --source [IP]    Specify the IP to run the check against.
    -h --help           Show this message and exit.
    -s --battle         Experimental space battle simulator.
    -v --version        Show version information and exit.

Note: Do not abuse this script! Frequent checks can make things worse. Run
once and collect the information. Get delisted. That's it."

# Email hosts
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

# Option options
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -b|--source)
      SOURCE_ADDR="$2"
      shift
      shift
    ;;
    -h|--help)
      echo "${MSG_HELP}"
      exit
    ;;
    -s|--battle)
      SOURCE_ADDR="$2"
      shift
      shift
    ;;
    -v|--version)
      echo "${VERSION}"
      exit
    ;;
    *)
      echo "Unknown option $1"
      echo "${MSG_HELP}"
      exit
    ;;
  esac
done

# Test if SOURCE_ADDR is valid or not; this runs a local telnet session that
# attempts to bind the IP. If it can't bind, there's no sense continuing.
if [[ -v SOURCE_ADDR ]]; then
  if { echo "quit"; sleep 1.5; } \
      | telnet -b "${SOURCE_ADDR}" 127.0.0.1 25 2>&1 \
      | grep -Eiq "couldn't bind to|cannot assign|couldn't get|could not resolve|invalid argument"; then

    echo "Specified IP is invalid or not available. Aborting attempt.";
    unset SOURCE_ADDR
    exit
  fi
fi

# Check for additional IPs; this uses the cPanel API to fetch all public IPs on
# the server. An initial check makes sure the whmapi1 command is available in
# case this script is run on a non-cPanel server.
if [[ -x /usr/local/cpanel/bin/whmapi1 ]]; then
  if whmapi1 listips | sed "/$(hostname -i)/d" | grep -iq "public_ip:"; then
    echo -e "${TEXT_BOLD}Found one or more dedicated IPs.${TEXT_RESET} Use '-b [IP]' to re-run against them:"

    echo -e "$(whmapi1 listips | sed "/$(hostname -i)/d" | grep -i "public_ip:" \
      | awk '{print "* "$2}')\n"
  fi
fi

# Display the IP we're checking against
if [[ -v SOURCE_ADDR ]]; then
  echo -e "${TEXT_BOLD}Checking ${SOURCE_ADDR}...${TEXT_RESET}\n"; else
  echo -e "${TEXT_BOLD}Checking $(hostname -i)...${TEXT_RESET}\n"
fi

# Loop through the HOSTS list and run the telcheck
for HOST in "${HOSTS[@]}"; do
  # Hotmail and Outlook use the same infrastructure. To avoid a useless lookup
  # we intercept and forward the results from Hotmail to the Outlook check. The
  # actual check code is further down and explained there.
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

  # Same for AOL/Verizon/Yahoo
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

  # Runs telnet with our commands, SOURCE_ADDR (if set), and HOST. Most mail
  # hosts won't tell us we're blocked until we at least attempt to send a
  # message (mail from:).
  check_host() {
    { sleep 1.5; echo "ehlo $(hostname)"; sleep 1.5; echo "mail from: <root@$(hostname)>"; sleep 1.5; echo "quit"; sleep 1.5; } \
      | telnet ${SOURCE_ADDR:+"-b" "${SOURCE_ADDR}"} "$(echo "${HOST}" | awk '{print $2}')" 25 2>&1
  }

  # Run check_host() and grep its output into a variable for further use
  RESPONSE="$(check_host \
    | grep -Ei "block|blacklist|not allowed|banned|denied|rejected|ivmsip|invaluement|sorbs|spamcop|spamhaus|dnsbl|dnsrbl|rbl|found on one or more")"

  # If RESPONSE had a match, we're blocked
  if [[ -n "${RESPONSE}" ]]; then
    IS_BLOCKED='true'
    RESULT="${TEXT_RED}FAIL${TEXT_RESET}"; else
    RESULT="${TEXT_GREEN}OK${TEXT_RESET}"
  fi

  # Display the host and its result (OK or FAIL)
  echo -e "${TEXT_BOLD}* $(echo "${HOST}" | awk -F "," '{print $1}') [${RESULT}${TEXT_BOLD}]${TEXT_RESET}"

  # For blocked results, we need to also show the error message
  if [[ -n "${RESPONSE}" ]]; then
    echo "🚫 ${RESPONSE})"
  fi

  # Setup for the Verizon/Yahoo check further up
  if [[ "${HOST}" == "Aol"* ]]; then
    AOL_RESPONSE="${RESPONSE}"
  fi

  # Same for the Outlook check
  if [[ "${HOST}" == "Hotmail"* ]]; then
    HOTMAIL_RESPONSE="${RESPONSE}"
  fi
done

# Final summary message and cleanup for telcheck.min
if [[ -v IS_BLOCKED ]]; then
  echo -e "\nBlock(s) detected. Follow the steps in the above output(s) to delist."
  unset IS_BLOCKED; else
  echo -e "\nAll clear! No blocks detected."
fi

# Unset SOURCE_ADDR for telcheck.min
if [[ -v SOURCE_ADDR ]]; then
  unset SOURCE_ADDR
fi
