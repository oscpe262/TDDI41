#!/bin/bash
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

### EOF ###
