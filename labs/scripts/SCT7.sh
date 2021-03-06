#!/bin/bash
source common.sh
# 7-1 Write a script that can add users in bulk to your system. It needs to
# accept input consisting of one name per line. Names can contain multiple
# words, unusual characters, anything.

### SCT7 MAIN SCRIPT ###########################################################

  [[ ! `uname -n` == "server" ]] && exit 0

  print_title "SCT7 SETUP SCRIPT"
  [[ ! -f "/root/users" ]] && echo "The file /root/users could not be found." && pause && return 1 || INFILE=/root/users

  # Read the usernames from file.
  print_title "ADDING USERS (${INFILE})"

  while read NAME; do
    print_info "Processing ${NAME}"
    # Remove sucky characters and make it all nice lowercase.
    NAME=$( echo "$NAME" | tr 'A-Z' 'a-z' | sed 's/[^ab-z]//g ; s/[åäö]//g')

    # Do magic!
    techo "a) Calculate a unique username for the user (${Yellow}userGen${Reset} ${NAME})"
    userGen &
    pid=$! ; progress $pid ; NAME=`cat /dev/shm/name`

    techo "b,d) Add the user and create home dir (${Yellow}addUser${Reset} ${NAME})"
    addUser &
    pid=$! ; progress $pid

    techo "c) Generate a random password for the user (${Yellow}pwGen${Reset})"
    pwGen &
    pid=$! ; progress $pid ; PASSWD=`cat /dev/shm/name` ; rm /dev/shm/name

    USERS[${NAME}]=${PASSWD}

    techo "d) Copy standard files to home dir. (${Yellow}cpFiles${Reset})"
    cpFiles &
    pid=$! ; progress $pid

    techo "e) Configure any services that need to be configured. (${Yellow}configServices${Reset})"
    configServices &
    pid=$! ; progress $pid

    print_line
  done < $INFILE

  print_info "Generated ${Blue}users${Reset}${BOLD} and ${Yellow}passwords:"

  # Iterate over an array with all USERS keys
  for E in "${!USERS[@]}"; do
    printf "\t%s" "${BBlue}${E}${Reset} "
    [[ ${#E} -le 20 ]] && printf "%*s" $(( 20-${#E})) ""
    printf "%s\n" "${BYellow}${USERS[$E]}${Reset}"
    unset USERS[$E]
  done; echo ""

  techo "${Reset}f) Output the username and password on a single line${Reset}" ; tested_ok "Passed!"
    #Yeah, those resets are just there for looks, literally...

  pause
  /etc/init.d/autofs restart
  nisrestart

  # No user input apart from the list of names is allowed. The script may need to
  # do other things as well. Part of your job is to figure out what. Your script
  # also needs to be as fast as possible. Anything that can be done once for the
  # entire run should be done only once (e.g. restarting certain services).

  # Data files for testing are available in /home/TDDI09.

  # Report: After the last lab, hand in your script. You will have to demonstrate it as well.

### EOF ###
