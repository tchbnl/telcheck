#!/bin/bash
# telcheck: Check for email blocks with telnet
# Nathan Paton <code@tchbnl.net>
# v0.9 R2 (Updated on 12/14/2022)

# Some of this stuff won't work on Bash versions before 4.2
if [[ "${BASH_VERSINFO[0]}${BASH_VERSINFO[1]}" -lt "42" ]]; then
  echo "telcheck requires at least Bash 4.2 to work. Your version is ${BASH_VERSION}."
  exit
fi

# It's rare, but sometimes telnet isn't installed
if ! command -v telnet >/dev/null; then
  echo "telcheck requires telnet to work. Hence the name 'tel(net)check'."
  exit
fi

# In case of repeated telcheck.min runs, we unset some variables first
unset SOURCE_IP
unset VERBOSE
unset IS_BLOCKED

# Version and last update date
VERSION="telcheck 0.9 R2 (Updated on 12/14/2022)"

# Text formatting
TEXT_BOLD="\e[1m"
TEXT_RESET="\e[0m"

# Help message
HELP_MESSAGE="telcheck is a simple email block checker using telnet.

USAGE: telcheck [-b IP]
  -b --source [IP]        Run check against the given IP address.
  -h --help               Show this message and exit.
  -v --version            Show version information and exit.
  -s --batle              Experimental space battle simulator.
  -V --verbose            Show full host responses regardles of a block.

Note: Do not abuse this script! Frequent checks can make things worse. Run once
and collect the information. Get delisted. That's it."

# Left is the host and display text for the check output. Right is the actual
# MX record run through telnet.
HOSTS=("Yahoo! (+ AOL and Verizon), mta5.am0.yahoodns.net"
       "ATT, al-ip4-mx-vip1.prodigy.net"
       "Comcast, mx1a1.comcast.net"
       "Cox\U2122, cxr.mx.a.cloudfilter.net"
       "EarthLink, mx01.oxsus-vadesecure.net"
       "Gmail, gmail-smtp-in.l.google.com"
       "Outlook (+ Hotmail), outlook-com.olc.protection.outlook.com")

# Command options
while [[ "${#}" -gt 0 ]]; do
  case "${1}" in
    -b|--source|-s|--battle)
      # Make sure an IP is given, and if so, set our SOURCE_IP
      # TODO: Add a check to make sure what looks like an IP is given
      if [[ -z "${2}" ]]; then
        echo "You must specify an IP address to check with. Use '-b IP'."
        exit
      else
        SOURCE_IP="${2}"
        shift 2
      fi
      ;;

    -h|--help)
      echo "${HELP_MESSAGE}"
      exit
      ;;

    -v|--version)
      echo "${VERSION}"
      exit
      ;;

    -V|--verbose)
      VERBOSE="Yes"
      shift 1
      ;;

    -*)
      echo -e "Not sure what '${1}' is supposed to be.\n"
      echo "${HELP_MESSAGE}"
      exit
      ;;
  esac
done

# Make sure the IP being used can be bound to and can talk to a local mail
# server. If it can't, we bail here.
if (sleep 1; echo "QUIT") | telnet ${SOURCE_IP:+-b ${SOURCE_IP} }127.0.0.1 25 2>&1 \
  | grep -Eiq "unable to connect|can't assign|cannot assign|nodename nor servname provided|couldn't get address|could not get address|name or service not known"; then
  echo -e "${TEXT_BOLD}Error:${TEXT_RESET} IP address is invalid or not" \
  "available. telcheck requires a public IP address assigned to the server in order to work.\n"
  echo "IP: ${SOURCE_IP:-"$(hostname -i)"}"
  exit
fi

# This uses the cPanel API to fetch all usable IPs on the server. A check for
# the 'whmapi1' command is done first to make sure this will work.
if [[ -x /usr/local/cpanel/bin/whmapi1 ]]; then
  if whmapi1 listips | sed '/'"$(hostname -i)"'/d' | grep -iq "public_ip:"; then
    echo -e "${TEXT_BOLD}Found one or more additional IP addresses:${TEXT_RESET}"
    whmapi1 listips | sed '/'"$(hostname -i)"'/d' | grep -i "public_ip:" \
    | awk -F ': ' '{print "* " $2}'
    echo -e "You can check a different IP address with '-b IP'.\n"
  fi
fi

# Literally a waste of SLOC
# Random text shown when starting a check
WAIT_TEXT=("Reticulating splines"
           "Enumerating beagles"
           "Rotating hedges"
           "Formulating ruses")

# Show the IP we're checking against
echo -e "${TEXT_BOLD}${SOURCE_IP:-"$(hostname -i)"}${TEXT_RESET}"
echo -e "Please wait. ${WAIT_TEXT[$((RANDOM % ${#WAIT_TEXT[@]}))]}...\n"

# List of terms to grep with further down
BAD_WORDS="banned|blacklist|blacklisted|block|blocklisted|denied|dnsbl|dnsrbl|found on one or more|invaluement|ivmsip|is on a|not allowed|rbl|rejected|sorbs|spamcop|spamhaus"

# Behold! The telcheck. We send a set of commands to telnet against each host
# server. In most cases a host won't report a block until we at least set a
# from address. We sleep between each command to give the host enough time to
# respond. Setting this below 1.5 tends to break some host checks.
telcheck_cmd() {
  (sleep 1.5; echo "EHLO $(hostname)"; sleep 1.5; echo "MAIL FROM: <root@$(hostname)>"; sleep 1.5; echo "QUIT") \
  | telnet ${SOURCE_IP:+-b ${SOURCE_IP} }"${*}" 25 2>&1
}

# Run the telcheck against each host
for HOST in "${HOSTS[@]}"; do
  echo -e "${TEXT_BOLD}$(echo "${HOST}" | awk -F ',' '{print $1}')${TEXT_RESET}"

  # We variablize the telcheck for further grepping below
  # The weird variable name is to make this text line up with the stuff above
  TRESULT="$(telcheck_cmd "$(echo "${HOST}" | awk -F ', ' '{print $2}')")"

  # And here are the results of that greppage
  if echo "${TRESULT}" | grep -Eiq "${BAD_WORDS}"; then
    echo -e "\U26D4 Fail"
    # We set IS_BLOCKED for the result summary at the end of thsi script
    IS_BLOCKED="Yes"

    # Show the result message if VERBOSE isn't set
    if [[ ! -v VERBOSE ]]; then
      echo "${TRESULT}" | grep -Ei "${BAD_WORDS}"
    fi
  else
    echo -e "\U1F44D Pass"
  fi

  # Because if VERBOSE is set, we show the entire telnet output instead
  if [[ -v VERBOSE ]]; then
    echo "${TRESULT}"
  fi
  echo
done

# Final results summary
if [[ -v IS_BLOCKED ]]; then
  echo "One or more blocks detected! Follow the instructions from the output above to delist."
else
  echo "All clear! No blocks detected."
fi
