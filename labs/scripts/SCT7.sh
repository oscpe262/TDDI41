#!/bin/bash
# 7-1 Write a script that can add users in bulk to your system. It needs to
# accept input consisting of one name per line. Names can contain multiple
# words, unusual characters, anything.

### CONFIG VARIABLES
# These are variables used throughout the script. Adjust to fit your desires.
declare -A USERS      # Users array (associative).
CGROUPS="users"       # Comma-separated list of groups. Default: GROUPS=users
CSHELL="/bin/bash"    # Shell for added users. Default: /bin/bash
USUF=5                # Suffix Length in case of conflicting usernames
PWLENGTH=8            # Length of passwords generated
CPHOME=()             # Array of files to be copied to homedir of each user
TOUCH=(".aliases")    # Array of empty files to be created in homedirs

[[ ! -f SCT7_funcs.sh ]] && echo -e "Missing dependency: SCT7_funcs.sh" && exit 1
source SCT7_funcs.sh

# Make sure we run this script properly!
[[ $1 == "-h" ]] && helpme && exit 0
[[ $# -eq 0 ]] && helpme && exit 1
[[ ! -f "$1" ]] && cecho "The file $1 could not be found." && exit 1
[[ "$(id -u)" != "0" ]] && echo -e "ERROR! You must execute the script as 'root'." && exit 1
INFILE=$1 && shift

while [ $# -ne 0 ]; do
  arg="$1"
  case "$arg" in
    # Failed tests will force the script to exit.
    -h)
      helpme
      exit 0
      ;;
    -l)
      # To allow testing, DRYRUN is enabled by default.
      DRYRUN=0
      ;;
    -f)
      FORCE_EXIT=1
      ;;
    -v)
      VERBOSE=1
      ;;
    -fv)
      FORCE_EXIT=1
      VERBOSE=1
      ;;
    -vf)
      FORCE_EXIT=1
      VERBOSE=1
      ;;
    *)
      echo -e "Unknown argument ${arg}. Run ${0} -h"
      exit 1
      ;;
  esac
  shift
done

### MAIN SCRIPT STARTS HERE
tput clear
print_title "SCT7 SETUP SCRIPT"
print_info "Welcome!"
[[ $DRYRUN -eq 1 ]] && print_info "During a dry run, no permanent changes will be made to the system. Therefore, duplicate users can still be listed if not already present. Run the script with -l to go live!" && sleep 1

# This part is for testing purposes only.
if [[ $DRYRUN -eq 0 ]]; then
  print_info "${BRed}YOU ARE LIVE! CHANGES WILL BE MADE TO THE SYSTEM. PROCEED? ([N]/y)${Reset} "
  read -n1 LIVE
  LIVE=$(echo ${LIVE} | tr 'A-Z' 'a-z')
  [[ ! ${LIVE} == y ]] && exit 0
fi
# End of dry-run option.

# Read the usernames from file.
print_title "ADDING USERS"
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

  techo "Setting owner for home dir and its contents (${Yellow}chown${Reset})"
  [[ $DRYRUN -eq 0 ]] && chown -R $NAME:$NAME /home/$NAME/ &
  pid=$! ; progress $pid

  print_line
done < $INFILE
#sleep 2

print_info "Generated ${Blue}users${Reset}${BOLD} and ${Yellow}passwords:"
for E in "${!USERS[@]}"; do
#  echo -e "\t${BBlue}${E}${Reset} : ${BYellow}${USERS[$E]}${Reset}"
  printf "\t%s" "${BBlue}${E}${Reset} "
  [[ ${#E} -le 20 ]] && printf "%*s" $(( 20-${#E} )) ""
  printf "%s\n" "${BYellow}${USERS[$E]}${Reset}"
done; echo ""

techo "${Reset}f) Output the username and password on a single line${Reset}" ; tested_ok "Passed!"
  #Yeah, those resets are just there for looks, literally...
print_line

# No user input apart from the list of names is allowed. The script may need to
# do other things as well. Part of your job is to figure out what. Your script
# also needs to be as fast as possible. Anything that can be done once for the
# entire run should be done only once (e.g. restarting certain services).

# Data files for testing are available in /home/TDDI09.

# Report: After the last lab, hand in your script. You will have to demonstrate it as well.
