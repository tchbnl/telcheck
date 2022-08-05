#!/bin/bash
#
# Check for email blocks with telnet
#
# Nathan Paton <nathanpat@inmotionhosting.com>
#
# v0.9 Updated on 8/5/2022
#
# Releases
# * v0.1: Initial release
# * v0.2: Support for additional IPs added;
#         Fancy text support added
# * v0.3: Fixes to edge case detections
# * v0.4: Apologies to EarthLink Corporation;
#         Fixed spelling for "EARTLINK_HOST"
# * v0.5: Raised send delay on telnet to fix edge cases
# * v0.6: Fastmail added to hosts list;
#         Reworked IP check to use cPanel API;
#         Fancy text overhaul;
#         Lowered send delay on telnet a little
# * v0.7: Reworked check code to be more compact
# * v0.8: Reworked check code to avoid useless lookups
# * v0.9: Reworked code to some semblance of standards
# * v1.0: Space battle simulator fully implemented

# Version number and revision date
VERSION="telcheck 0.9 (Updated on 8/5/2022)"

# Fancy text
TEXT_BOLD="\e[1m"
TEXT_GREEN="\e[32m"
TEXT_RED="\e[31m"
TEXT_RESET="\e[0m"

# Help message
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

# Get our options
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
    -*|--*)
      echo "Unknown option $1"
      echo "${MSG_HELP}"

      exit
    ;;
    *)
      echo "Unknown option $1"
      echo "${MSG_HELP}"

      exit
    ;;
  esac
done

# This runs telnet with "-b SOURCE_ADDR" and pipes the output to grep. If it
# returns a match, the condition is met and our error message is returned. We
# use "-q" to suppress the actual output so the check is nice and quiet.
if [[ -v SOURCE_ADDR ]]; then
  if { echo "quit"; sleep 1.5; } \
    | telnet -b "${SOURCE_ADDR}" 127.0.0.1 25 2>&1 \
    | grep -Eiq "couldn't bind to|cannot assign|couldn't get|could not resolve|invalid argument"; then

    echo "Specified IP is invalid or not available. Aborting attempt."; unset SOURCE_ADDR

    exit
  fi
fi

# First we check to make sure the whmapi1 command exists; this check only works
# on cPanel servers. Then, we run listips and remove our hostname IP from the
# output. If other IPs are still returned, we can list them for the user. If no
# other IPs are returned, we exit silently and forget all this happened.
if [[ -x /usr/local/cpanel/bin/whmapi1 ]]; then
  if whmapi1 listips | sed "/$(hostname -i)/d" | grep -iq "public_ip:"; then
    echo -e "${TEXT_BOLD}Found one or more dedicated IPs.${TEXT_RESET} Use '-b [IP]' to re-run against them:"
    echo -e "$(whmapi1 listips | sed "/$(hostname -i)/d" | grep -i "public_ip:" \
      | awk '{print "* "$2}')\n"
  fi
fi

# Show the IP being checked
if [[ -v SOURCE_ADDR ]]; then
  echo -e "${TEXT_BOLD}Checking ${SOURCE_ADDR}...${TEXT_RESET}\n"; else
  echo -e "${TEXT_BOLD}Checking $(hostname -i)...${TEXT_RESET}\n"
fi

# We use a loop to run each server from HOSTS through telnet and filter the
# output for words that suggest there's a block. If the filter returns a
# match, the RESULT is fail and we set IS_BLOCKED for the final results message
# at the end of this script.
for HOST in "${HOSTS[@]}"; do

  # Hotmail and Outlook are the same, so we avoid a useless lookup and wasted
  # seconds by forwarding the result for Hotmail to Outlook. The actual check
  # is further down; this is to catch it before it runs.
  if [[ "${HOST}" == "Outlook"* ]]; then

    # If RESPONSE contains a match from the above filter, set IS_BLOCKED and
    # fail the RESULT - otherwise the RESULT is OK.
    if [[ -n "${HOTMAIL_RESPONSE}" ]]; then
      IS_BLOCKED="true"
      RESULT="${TEXT_RED}FAIL${TEXT_RESET}"; else
      RESULT="${TEXT_GREEN}OK${TEXT_RESET}"
    fi

    # Return the host and its check result
    echo -e "${TEXT_BOLD}* $(echo "$HOST" | awk -F "," '{print $1}') [$RESULT${TEXT_BOLD}]${TEXT_RESET}"

    # Also return the RESPONSE if there was a match
    if [[ -n "${HOTMAIL_RESPONSE}" ]]; then
      echo "🚫 ${HOTMAIL_RESPONSE}"
    fi

    # Run the next item in the loop
    continue
  fi

  # Verizon and Yahoo use AOL's mail service
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

  # Run the telcheck; this is similar to our SOURCE_ADDR check further up. We
  # variablize the result and then filter it below.
  check_host() {
    { sleep 1.5; echo "ehlo $(hostname)"; sleep 1.5; echo "mail from: <root@$(hostname)>"; sleep 1.5; echo "quit"; sleep 1.5; } \
    | telnet ${SOURCE_ADDR:+"-b" "${SOURCE_ADDR}"} "$(echo "${HOST}" | awk '{print $2}')" 25 2>&1
  }

  # Variablize and run check, then filter its output
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

  # Set AOL variable for duplicate host check
  if [[ "${HOST}" == "Aol"* ]]; then
    AOL_RESPONSE="${RESPONSE}"
  fi

  # Set Hotmail variable for duplicate host check
  if [[ "${HOST}" == "Hotmail"* ]]; then
    HOTMAIL_RESPONSE="${RESPONSE}"
  fi
done

# Final check results and cleanup
if [[ -v IS_BLOCKED ]]; then
  echo -e "\nBlock(s) detected. Follow the steps in the above output(s) to delist."

  unset IS_BLOCKED; else
  echo -e "\nAll clear! No blocks detected."
fi

# Unset SOURCE_ADDR for future runs (for direct shell version)
if [[ -v SOURCE_ADDR ]]; then
  unset SOURCE_ADDR
fi
