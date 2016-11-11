#!/bin/bash
defpingc=3 #default amount of ping tries
FORCE_EXIT=0
VERBOSE=0
[[ -z $1 ]] && echo -e "run with ./`basename $0` <hostname>" && exit 1
HOST=$1 && shift

while [ $# -ne 0 ]
do
  arg="$1"
  case "$arg" in
    # Failed tests will force the script to exit.
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
      echo -e "unknown argument '${arg}'"
      ;;
  esac
  shift
done

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
  local _line="${Blue}[${Reset}X${Blue}]${Reset} ${1}:"
  printf "%s" "${_line}"
  printf "%*s" $(( ($(tput cols) / 2)-${#_line} )) ""
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
      if [[ $retcode == 0 ]] || [[ $retcode == 255 ]]; then
        tested_ok
      else
        error_msg
      fi
      break
    fi
  done
}

tested_ok () {
  cecho "${Green}Passed!${Reset}"
}

error_msg () {
  echo -e "${Red}Failed!${Reset}" >&2
  echo -e "${Red}Failed!${Reset}" >> "$LOG"
  [[ $FORCE_EXIT -eq 1 ]] && echo -e "Forced Exit active!" && exit 1
}

check_hostname () {
  techo "${Yellow}Hostname${Reset} set properly"
  [[ `uname -n` == "${1}" ]] &
  pid=$!; progress $pid
}

ping_test () {
#ping target_ip test_description [ping count]
  local _target="$1"
  local _test="$2"
  local _count=""
  [[ -z $3 ]] && _count=$defpingc || _count=$3
  #techo "Ping ${Yellow}${_target}${Reset} (${_test})"
  techo "Ping ${Yellow}${_target}${Reset} (${_test})"
  if [[ $VERBOSE -eq 1 ]]; then
    ping -c ${_count} ${_target}
  else
     ping -c ${_count} ${_target} &> /dev/null &
     pid=$!; progress $pid
  fi
}
