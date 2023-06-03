#!/bin/bash
# telcheck: Check for email blocks with telnet
# Nathan Paton <me@tchbnl.net>
# v0.9 R2 (Updated on 6/3/2023)

# Some of this stuff won't work on Bash versions before 4.2
# Use telnet.el6.min.sh for old servers
if [[ "${BASH_VERSINFO[0]}${BASH_VERSINFO[1]}" -lt "42" ]]; then
  echo "telcheck requires at least Bash 4.2 to work. Your version is ${BASH_VERSION}."
  exit
fi

# It's rare, but sometimes telnet isn't installed
if ! command -v telnet >/dev/null 2>&1; then
  echo "telcheck requires telnet to work. Hence the name 'tel(net)check'."
  exit
fi

# Unset some variables in case this is telcheck.min.sh
unset SOURCE_IP
unset VERBOSE
unset IS_BLOCKED

# Version information
VERSION="telcheck 0.9 R2 (Updated on 6/3/2023)"

# Nice text formatting
TEXT_BOLD="\e[1m"
TEXT_RESET="\e[0m"

# Help message
HELP_MESSAGE="telcheck is a simple email block checker using telnet.

USAGE: telcheck [-b IP]
  -b --source [IP]        Run check against the given IP address.
  -h --help               Show this message and exit.
  -v --version            Show version information and exit.
  -s --battle             Experimental space battle simulator.
  -V --verbose            Show full host responses regardles of a block.

Note: Do not abuse this script! Frequent checks can make things worse. Run once
and collect the information. Get delisted. That's it."

# Left is the host and display text for the check output. Right is the actual MX
# record we run through telnet.
HOSTS=("Yahoo! (+ AOL and Verizon), mta5.am0.yahoodns.net"
       "ATT, al-ip4-mx-vip1.prodigy.net"
       "Comcast, mx1a1.comcast.net"
       "Cox™, cxr.mx.a.cloudfilter.net"
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

# Make sure the IP being used can be bound to and can talk to a local mail server
if (sleep 1; echo "QUIT") | telnet ${SOURCE_IP:+-b ${SOURCE_IP} }127.0.0.1 25 2>&1 \
  | grep -Eiq "unable to connect|can't assign|cannot assign|nodename nor servname provided|couldn't get address|could not get address|name or service not known"; then
  echo -e "${TEXT_BOLD}Error:${TEXT_RESET} IP address is invalid or not" \
  "available. telcheck requires a public IP address assigned to the server in order to work.\n"
  echo "IP: ${SOURCE_IP:-"$(hostname -i)"}"
  exit
fi

# This uses the cPanel API to fetch all usable IPs on the server. A check for
# the 'whmapi1' command is done first to make sure this will work.
# TODO: Rewrite this to not require cPanel
#if [[ -x /usr/local/cpanel/bin/whmapi1 ]]; then
#  if whmapi1 listips | sed '/'"$(hostname -i)"'/d' | grep -iq "public_ip:"; then
#    echo -e "${TEXT_BOLD}Found one or more additional IP addresses:${TEXT_RESET}"
#    whmapi1 listips | sed '/'"$(hostname -i)"'/d' | grep -i "public_ip:" \
#    | awk -F ': ' '{print "* " $2}'
#    echo -e "You can check a different IP address with '-b IP'.\n"
#  fi
#fi

# Get all non-local IPs on the server
# Yes I swear I'll update this for IPv6 soon
if [[ "$(hostname -I | xargs -n 1 | grep -Evc '^127.|^10.|^172.|^192.')" -gt 1 ]]; then
  echo -e "${TEXT_BOLD}Found one or more additional IP addresses:${TEXT_RESET}"
  hostname -I | xargs -n 1 | grep -Ev '^127.|^10.|^172.|^192.' | awk '{print "* " $0}'
  echo -e "You can check a different IP address with '-b IP'.\n"
fi

# Random text shown when starting a check
WAIT_TEXT=("Reticulating splines"
           "Enumerating beagles"
           "Rotating hedges"
           "Formulating ruses")

# Show the IP we're checking against
echo -e "${TEXT_BOLD}${SOURCE_IP:-"$(hostname -i)"}${TEXT_RESET}"
echo -e "Please wait. ${WAIT_TEXT[$((RANDOM % ${#WAIT_TEXT[@]}))]}...\n"

# List of terms we grep for further down
BAD_WORDS="banned|blacklist|blacklisted|block|blocklisted|denied|dnsbl|dnsrbl|found on one or more|invaluement|ivmsip|is on a|not allowed|rbl|rejected|sorbs|spamcop|spamhaus"

# The actual check. We connect to the mail server and run some commands - most hosts
# won't tell us if we're blocked until we set our from address. A delay between each
# command ensures there's enough time for the mail server to respond.
# I know this is slow. Setting sleep below 1.5 causes wonkiness with some mail hosts
telcheckit() {
  (sleep 1.5; echo "EHLO $(hostname)"; sleep 1.5; echo "MAIL FROM: <root@$(hostname)>"; sleep 1.5; echo "QUIT") \
  | telnet ${SOURCE_IP:+-b ${SOURCE_IP} }"${*}" 25 2>&1
}

# Run the telcheck against each host
for HOST in "${HOSTS[@]}"; do
  echo -e "${TEXT_BOLD}$(echo "${HOST}" | awk -F ',' '{print $1}')${TEXT_RESET}"

  # We variablize the telcheck for further grepping below
  # The weird variable name is to make this text line up with the stuff above
  TRESULT="$(telcheckit "$(echo "${HOST}" | awk -F ', ' '{print $2}')")"

  # And here are the results of that greppage
  if echo "${TRESULT}" | grep -Eiq "${BAD_WORDS}"; then
    echo -e "⛔ Fail"
    # We set IS_BLOCKED for the result summary at the end of thsi script
    IS_BLOCKED="Yes"

    # Show the result message if VERBOSE isn't set
    if [[ ! -v VERBOSE ]]; then
      echo "${TRESULT}" | grep -Ei "${BAD_WORDS}"
    fi
  else
    echo -e "👍 Pass"
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
