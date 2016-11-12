#!/bin/bash
FORCE_EXIT=0
VERBOSE=0
DRYRUN=0

### TYPE SETTING ###############################################################
  BOLD=$(tput bold)
  ULINE=$(tput sgr 0 1)
  Reset=$(tput sgr0)
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
  clear
  local _title="${BYellow}${1}${Reset}"
  print_line "#" "${BBlue}"
  printf "%*s\n" $(( (${#_title} + $(tput cols)) / 2)) "${_title}"
  print_line "#" ${BBlue}
  echo ""
}

print_info() {
  T_COLS=`tput cols`
  echo -e "${BOLD}$1${Reset}\n" | fold -sw $(( $T_COLS - 18 )) | sed 's/^/\t/'
}

tested_ok () {
  cecho "${Green}${1}${Reset}"
}

error_msg () {
  echo -e "${Red}${1}${Reset}" >&2
  echo -e "${Red}${1}${Reset}" >> "$LOG"
  [[ $FORCE_EXIT -eq 1 ]] && echo -e "Forced Exit active!" && exit 1
}
