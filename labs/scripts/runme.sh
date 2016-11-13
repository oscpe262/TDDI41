#!/bin/bash
################################################################################
# TDDI41 2016 Main Script by oscpe262 and matla782
#
# This script is for TDDI41:b4 use only. No warranties - you are responsible for
# any consequence of not knowing what it does.
# This script is somewhat inspired by oscpe262's revamp of helmuthdu's Arch
# Ultimate Install , which can be found at https://github.com/helmuthdu/aui .
################################################################################

FORCE_EXIT=0
VERBOSE=0
DRYRUN=0

### TYPE SETTING ###############################################################

  BOLD=$(tput bold)
  ULINE=$(tput sgr 0 1)
  Reset=$(tput sgr0)
  BReset=${Reset}${BOLD}
# REGULAR COLOURS
  Red=$(tput setaf 1)
  Green=$(tput setaf 2)
  Yellow=$(tput setaf 3)
  Blue=$(tput setaf 4)
  Purple=$(tput setaf 5)
  Cyan=$(tput setaf 6)
  White=$(tput setaf 7)
# BOLD COLOURS
  BRed=${BOLD}$(tput setaf 1)
  BGreen=${BOLD}$(tput setaf 2)
  BYellow=${BOLD}$(tput setaf 3)
  BBlue=${BOLD}$(tput setaf 4)
  BPurple=${BOLD}$(tput setaf 5)
  BCyan=${BOLD}$(tput setaf 6)
  BWhite=${BOLD}$(tput setaf 7)

### MISC VARS ##################################################################

  LOG="`basename ${0}`.log"
  [[ -f $LOG ]] && rm -f $LOG

  nw=130.236.178
  gwe=${nw}.17
  gwi=${nw}.153
  srv=${nw}.154
  c1=${nw}.155
  c2=${nw}.156

  SPIN="/-\|"
  prompt1="Enter options (e.g: 1 2 3 or 1-3): "
  #prompt3="You have to manually enter the following commands, then press ${BYellow}ctrl+d${Reset} or type ${BYellow}exit${Reset}:"

  declare -A USERS      # Users array (associative).
  CGROUPS="users"       # Comma-separated list of groups. Default: GROUPS=users
  CSHELL="/bin/bash"    # Shell for added users. Default: /bin/bash
  USUF=5                # Suffix Length in case of conflicting usernames
  PWLENGTH=8            # Length of passwords generated
  CPHOME=()             # Array of files to be copied to homedir of each user
  TOUCH=(".aliases")    # Array of empty files to be created in homedirs

### SUPPORT FUNCS ##############################################################

cecho () {
  echo -e "$1" && echo -e "$1" >> "$LOG"
  tput sgr0
}
ncecho () {
  echo -ne "$1" && echo -ne "$1" >> "$LOG"
  tput sgr0
}

spinny() {
  echo -ne "\b${SPIN:i++%${#SPIN}:1}"
}

techo() {
  local _line="${Blue}[${Reset}X${Blue}]${Reset} ${1}:  "
  printf "%s" "${_line}"
  [[ $(tput cols) -ge 120 ]] && printf "%*s" $(( 120-${#_line} )) ""
}

progress() {
  while true; do
    kill -0 $pid &> /dev/null;
    if [[ $? == 0 ]]; then
      spinny
      sleep 0.25
    else
      ncecho "\b";
      wait $pid
      retcode=$?
      echo -ne "$pid's retcode: $retcode " >> $LOG
      [[ $DRYRUN -eq 1 ]] && dry_ok && break
      if [[ $retcode == 0 ]] || [[ $retcode == 255 ]]; then
        tested_ok "Passed!"
      else
        error_msg "Failed!"
      fi
      break
    fi
  done
}

print_line() {
  # usage: print_line [ char to repeat [ ${colour} ]]
  [[ -z "$1" ]] && CHAR='-' || CHAR="${1}"
  [[ -z "$2" ]] || printf "%s\r" "$2"
  printf "%$(tput cols)s\n" | tr ' ' "$CHAR"
  tput sgr0
}

print_title() {
  tput clear
  local _title="${BYellow}${1}${Reset}"
  print_line "#" "${BBlue}"
  printf "%*s\n" $(( (${#_title} + $(tput cols)) / 2)) "${_title}"
  print_line "#" ${BBlue}
  echo ""
}

print_info() {
  T_COLS=$((`tput cols` - 4 ))
  echo -e "${BOLD}$1${Reset}\n" | fold -sw $T_COLS | sed 's/^/\t/'
}

tested_ok () {
  cecho "${Green}${1}${Reset}"
}

error_msg () {
  echo -e "${Red}${1}${Reset}" >&2
  echo -e "${Red}${1}${Reset}" >> "$LOG"
  [[ $FORCE_EXIT -eq 1 ]] && echo -e "Forced Exit active!" && exit 1
}

pause() {
  print_line
  read -e -sn 1 -p "Press enter to continue..."
}

checkbox() {
  #display [X] or [ ]
  [[ "$1" -eq 1 ]] && echo -e "${BBlue}[${BReset}X${BBlue}]${Reset}" || echo -e "${BBlue}[ ${BBlue}]${Reset}";
}

#menu_item() {
#  #check if the number of arguments is less then 2
#  [[ $# -lt 2 ]] && _package_name="$1" || _package_name="$2";
#  #list of chars to remove from the package name
#  local _chars=("Ttf-" "-bzr" "-hg" "-svn" "-git" "-stable" "-icon-theme" "Gnome-shell-theme-" #"Gnome-shell-extension-");
#  #remove chars from package name
#  for char in ${_chars[@]}; do _package_name=`echo ${_package_name^} | sed 's/'$char'//'`; done
#  #display checkbox and package name
#  echo -e "$(checkbox_package "$1") ${Bold}${_package_name}${Reset}"
#}

mainmenu_item() {
  #if the task is done make sure we get the state
  if [ $1 == 1 -a "$3" != "" ]; then
    state="${BGreen}[${Reset}$3${BGreen}]${Reset}"
  fi
  echo -e "$(checkbox "$1") ${Bold}$2${Reset} ${state}"
}

eliret() {
  [[ $OPT == b || $OPT == d ]] && break;
}

read_text() {
  read -p "$1 ${Reset}[y/N]: " OPTION
  echo ""
  OPTION=`echo "$OPTION" | tr '[:upper:]' '[:lower:]'`
}

read_opts() {
  local _line
  local _opts

  read -p "$prompt1" OPTION
  array=("$OPTION")

  for _line in ${array[@]/,/ }; do
    if [[ ${_line/-/} != $_line ]]; then  #_line is something like "1-3"
      for ((i=${_line%-*}; i<=${_line#*-}; i++)); do
        _opts+=($i);
      done
    else                                  # _line is a space separated list
      _opts+=($_line)
    fi
  done
  OPTIONS=("${_opts[@]}")
}

invalid_option() {
  print_line
  echo "($1) is an invalid option."
  pause
}

### SCT7 FUNCS #################################################################

dry_ok() {
  cecho "${Blue}Dryrun!${Reset}"
}

randomString() {
  RAND=$(cat /dev/urandom | tr -dc ${VALCHAR} | fold -w $NOCHARS | head -n 1)
}

userGen() {
  local _LOOP=true
  # Check if user exists ... Returns UID or -1.
  if [ `id -u "$NAME"  2>/dev/null || echo -1` -ge 0 ]; then

    # If existing:
    # Generate a random string, append as USERNAME-STRING,
    # make sure it does not exist.
    while [ ${_LOOP} = true ];
    do
      VALCHAR="a-z"
      NOCHARS=$USUF
      randomString
      NAME="${NAME}-${RAND}"
      if [ `id -u "$NAME" 2>/dev/null || echo -1` -eq -1 ]; then
         _LOOP=false
      fi
    done
  fi
  echo -ne "$NAME" > /dev/shm/name
}

addUser() {
  # Add the users, default group being the same as the username and extra groups
  # (-G) defined in $CGROUPS, creating homedir (-m) and setting shell to $CSHELL (-s).
  #echo -e "\baddUser $NAME"
  [[ $DRYRUN -eq 0 ]] && useradd -m -G ${CGROUPS} -s ${CSHELL} ${NAME} 2>${LOG}
}

pwGen() {
  NOCHARS=$PWLENGTH
  VALCHAR="a-zA-Z0-9!#%&?_-"
  randomString
  PASSWD=${RAND}
  echo -ne "$PASSWD" > /dev/shm/name

# This isn't very safe, but as we're going to print it anyway later ...
  [[ $DRYRUN -eq 0 ]] && echo "${NAME}:${PASSWD}" | chpasswd 2>${LOG}
}

cpFiles() {
  for f in ${CPHOME[@]}; do
    echo -e "cp -r ${f} /home/${NAME}/$(basename ${f})" >> $LOG
    [[ $DRYRUN -eq 0 ]] && cp -r ${f} /home/${NAME}/$(basename ${f}) 2>${LOG}
  done

  for t in ${TOUCH[@]}; do
    echo -e "touch /home/${NAME}/${t}" >> $LOG
    [[ $DRYRUN -eq 0 ]] && touch /home/${NAME}/${t} 2>${LOG}
  done
}

reclaim() {
  [[ $DRYRUN -eq 0 ]] && chown -R $NAME:$NAME /home/$NAME/ 2>${LOG}
}

configServices() {
:
}

defpingc=3 #default amount of ping tries

ping_test () {
#ping target_ip test_description [ping count]
  local _target="$1"
  local _test="$2"
  local _count=""
  [[ -z $3 ]] && _count=$defpingc || _count=$3
  techo "Ping ${Yellow}${_target}${Reset} (${_test})"
  if [[ $VERBOSE -eq 1 ]]; then
    ping -c ${_count} ${_target}
  else
     ping -c ${_count} ${_target} &> /dev/null &
     pid=$!; progress $pid
  fi
}

check_hostname () {
  techo "${Yellow}Hostname${Reset} set properly"
  [[ `uname -n` == "${1}" ]] &
  pid=$!; progress $pid
}

### SCT7 MAIN SCRIPT ###########################################################

userscript() {
  print_title "SCT7 SETUP SCRIPT"
  [[ ! -f "${1}" ]] && cecho "The file ${1} could not be found." && pause && return 1 || INFILE=${1}

  # This part is for testing purposes only.
  if [[ $DRYRUN -eq 0 ]]; then
    read_text "${BRed}YOU ARE LIVE! CHANGES WILL BE MADE TO THE SYSTEM. PROCEED? "
    [[ ! ${OPTION} == y ]] && return 1
  fi
  # End of dry-run option.

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

    echo "trace: ${NAME}"
    USERS[${NAME}]=${PASSWD}

    techo "d) Copy standard files to home dir. (${Yellow}cpFiles${Reset})"
    cpFiles &
    pid=$! ; progress $pid

    techo "e) Configure any services that need to be configured. (${Yellow}configServices${Reset})"
    configServices &
    pid=$! ; progress $pid

    techo "Setting owner for home dir and its contents (${Yellow}chown${Reset})"
    reclaim &
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

  # No user input apart from the list of names is allowed. The script may need to
  # do other things as well. Part of your job is to figure out what. Your script
  # also needs to be as fast as possible. Anything that can be done once for the
  # entire run should be done only once (e.g. restarting certain services).

  # Data files for testing are available in /home/TDDI09.

  # Report: After the last lab, hand in your script. You will have to demonstrate it as well.
}

### NET TEST MAIN FUNCTION #####################################################

test_net() {
  check_hostname $HOST
  [[ ! $HOST == "client-2" ]] && ping_test "${c2}" "Client-2 Internal, IP"
  [[ ! $HOST == "client-1" ]] && ping_test "${c1}" "Client-1 Internal, IP"
  [[ ! $HOST == "server" ]] && ping_test "${srv}" "Server Internal, IP"
  [[ ! $HOST == "gw" ]] && ping_test "${gwi}" "Gateway Internal, IP"
  [[ ! $HOST == "gw" ]] && ping_test "${gwe}" "Gateway External, IP"
  ping_test "${nw}.1" "ida-gw, IP"
  ping_test "ida-gw.sysinst.ida.liu.se" "ida-gw"
  ping_test "www.google.com" "World-Wide Connectivity"
}

### TESTS BRANCH ###############################################################

tests() {
  DRYRUN=0
  while true
  do
    print_title "Test Scripts by oscpe262 and matla782"
    print_info ""
    echo " 1) $(mainmenu_item "${testlist[1]}" "Network test (${Yellow}NET${Reset})")"
    echo " b) Back to Main Menu"
    read_opts
    for OPT in ${OPTIONS[@]}; do
      case "$OPT" in
        1)
          test_net && testlist[1]=1
          ;;
        "b")
          DRYRUN=1
          break
          ;;
        *)
          invalid_option "$OPT"
          ;;
      esac
    done
    eliret
  done
}

### CONFIGS BRANCH #############################################################

configs() {
  while true
  do
    print_title "Configuration Scripts by oscpe262 and matla782"
    print_info "During a dry run, no permanent changes will be made to the system. Therefore, duplicate users in the infile can still be listed if not already present."
    echo " 1) $(mainmenu_item "${configlist[1]}" "Add users (${Yellow}SCT7${Reset}) ${Blue}Dry Run${Reset}")"
    echo " 2) $(mainmenu_item "${configlist[2]}" "Add users (${Yellow}SCT7${Reset}) ${BRed}Live Run${Reset}")"
    echo " b) Back to Main Menu"
    read_opts
    for OPT in ${OPTIONS[@]}; do
      case "$OPT" in
        1)
          DRYRUN=1
          print_line
          read -p "Filepath to list of users: " INFILE
          [[ -z ${INFILE} ]] && INFILE="/home/splatrat/test/users"
          userscript "${INFILE}" && configlist[1]=1
          ;;
        2)
          DRYRUN=0
          read -p "Filepath to list of users: " INFILE
          [[ -z ${INFILE} ]] && INFILE="/home/splatrat/test/users2"
          userscript "${INFILE}" && configlist[2]=1
          ;;
        "b")
          break
          ;;
        *)
          invalid_option "$OPT"
          ;;
      esac
    done
    eliret
  done
}

### MAIN VARIABLES #############################################################

checklist=( 0 0 0 )
testlist=( 0 0 0 )
configlist=( 0 0 0 )
maintitle="TDDI41 2016 Main Script by oscpe262 and matla782"

main(){
  print_title "${maintitle}"
}

### WELCOME ####################################################################

main
print_info "Welcome! Make sure you have read the documentation before you proceed!"
echo -e "Prerequisites:\n"
echo ">> Environment set according to TDDI41 first four labs."
echo ">> UML:s running, with SSH active and connectable."
echo -e ">> Configurated this set of scripts.\n"
print_line
echo -e "Cancel at any time with CTRL+C.\n"
pause


### MAIN MENU ##################################################################

while true; do
  main
  print_info "This script has two parts: ${Yellow}Tests${BReset} and ${BYellow}Configs${BReset}. ${Yellow}Tests${BReset} runs tests that are not covered in ${BYellow}Configs${BReset}, such as ${Blue}NET${BReset} configuration checks. ${BYellow}Configs${BReset} runs a series of scripts that configure the environment according to lab instructions."
  echo " 1) $(mainmenu_item "${checklist[1]}" "Configs")"
  echo " 2) $(mainmenu_item "${checklist[2]}" "Tests")"
  echo -e "\n q) Quit\n"
  read_opts
  for OPT in ${OPTIONS[@]}; do
    case "$OPT" in
      1)
        configs
        checklist[1]=1
        ;;
      2)
        tests
        checklist[2]=1
        ;;
      "q")
        exit 0
        ;;
      *)
        invalid_option "$OPT"
        ;;
    esac
  done
done

