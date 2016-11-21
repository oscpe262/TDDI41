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

  nodes=( "${gwi}" "${srv}" "${c1}" "${c2}" )
  nodenames=( "gw" "server" "client-1" "client-2" "betelgeuse" )
  confnodes=( 0 0 0 0 0 )

  tboxl="${BBlue}[${Reset}"
  tboxr="${BBlue}]${Reset}"
  tdone="${tboxl}${Green} ok ${tboxr}"
  tfail="${tboxl}${Red}fail${tboxr}"
  ttodo="${tboxl}${BReset} >> ${tboxr}"
  legend="${tdone} = Passed, ${tfail} = Failed, ${ttodo} = Not yet run"

  remote_path="/root"
  files=()
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
  local _line="${1}:  "
  printf "\n%s" "    ${_line}"
  [[ $(tput cols) -ge 120 ]] && printf "%*s" $(( 40-${#_line} )) ""
}

progress() {
  while true; do
    kill -0 $pid &> /dev/null;
    if [[ $? == 0 ]]; then
      spinny
      sleep 0.25
    else
      echo -ne "\b";
      wait $pid
      retcode=$?
      echo -ne "$pid's retcode: $retcode " >> $LOG
      [[ $DRYRUN -eq 1 ]] && dry_ok && return 0
      if [[ $retcode == 0 ]] || [[ $retcode == 255 ]]; then
        tested_ok "Passed!"
				return 0
      else
        error_msg "Failed!"
				return 1
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
  echo -e "\n\t${legend}"
  echo ""
}

print_info() {
  T_COLS=$((`tput cols` - 4 ))
  echo -e "${BOLD}$1${Reset}\n" | fold -sw $T_COLS | sed 's/^/\t/'
}

dry_ok() {
  echo -ne "${Magenta}DryRun!${Reset}"
}
tested_ok () {
  echo -ne "${Green}${1}${Reset}"
}

error_msg () {
  echo -ne "${Red}${1}${Reset}" >&2
#  echo -e "${Red}${1}${Reset}" >> "$LOG"
  [[ $FORCE_EXIT -eq 1 ]] && echo -e "Forced Exit active!" && exit 1
	return 1
}

pause() {
  echo ""
  print_line
  read -e -sn 1 -p "Press enter to continue..."
}
checkbox() {
  local _sign
  [[ $1 -eq 0 ]] && echo -e "${tdone}"
  [[ $1 -eq 1 ]] && echo -e "${tfail}"
  [[ $1 -ge 2 ]] && echo -e "${ttodo}"
}

mainmenu_item() {
  #if the task is done make sure we get the state
  if [[ $1 == 1 ]] &&  [[ "$3" != "" ]]; then
    state="${BGreen}[${Reset}$3${BGreen}]${Reset}"
  fi
  echo -e "$(checkbox "$1") ${Bold}$2${Reset} ${state}"
}

read_text() {
  read -p "$1 ${Reset}[y/N]: " OPTION
  echo ""
  OPTION=`echo "$OPTION" | tr '[:upper:]' '[:lower:]'`
}

prep_opts() {
	local _array=("$@")
	local _i=0
	OPTION=""

	for e in ${_array[@]}; do
		[[ $e -eq 2 ]] && OPTION+="${_i} "
		((_i++))
	done
}

read_opts() {
  local _line
  local _opts
	local i=0

  [[ -z $1 ]] && read -p "$prompt1" OPTION || OPTION=${1}
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

transfer() {
  echo "Using depracated function transfer(), replace with rsyncto"
  pause
  for node in ${nodes[@]}; do
    for file in ${files[@]}; do
      scp ${file} root@${node}:${remote_path}/
    done
  done
}

rsyncfrom() {
  local INFILE=$1
  local retval=0
  for srca in ${nodes[@]}; do
    [[ $srca == ${gwi} ]] && SRC="GW"
    [[ $srca == ${srv} ]] && SRC="SRV"
    [[ $srca == ${c1} ]] && SRC="CL1"
    [[ $srca == ${c2} ]] && SRC="CL2"
      while read FILE; do
        [[ ! $SRC == "GW" ]] && [[ $FILE == *"quagga"* ]] && continue
        [[ ! $SRC == "SRV" ]] && [[ $FILE == *"bind"* ]] && continue
        techo "$SRC ${FILE}"
        rsync -aruz -e "ssh" root@${srca}:${FILE} `pwd`/../configs/$SRC${FILE} &> /dev/null &
        pid=$!; progress $pid
        [[ ! $? == 0 ]] && retval=1
      done < ${INFILE}
      echo ""
    done
  return ${retval}
}

rsyncto(){
  local INFILE=$1
  local retval=0
  for srca in ${nodes[@]}; do
      while read FILE; do
        techo "$srca ${FILE}"
        rsync -aruz -e "ssh" ${FILE} root@${srca}:${remote_path}/ &> /dev/null &
        pid=$!; progress $pid
        [[ ! $? == 0 ]] && retval=1
      done < ${INFILE}
    done
  return ${retval}
}

inArray () {
  local e
  for e in "${@:2}"; do
		[[ "$e" == "$1" ]] && return 0
	done
  return 1
}

atoggle() {
  [[ $1 == 0 ]] && return 2 || return 0
}

node_select() {
confnodes=( 0 0 0 0 0 )
  while true; do
    print_title "Node Configuration Selection"
    print_info "Toggle nodes to be configured (default = all). Nodes can be reselected between configurations if desired."
    echo -e "\n 1) $(mainmenu_item "${confnodes[1]}" "Gateway (${Yellow}gw${Reset})")"
    echo -e " 2) $(mainmenu_item "${confnodes[2]}" "Server (${Yellow}server${Reset})")"
    echo -e " 3) $(mainmenu_item "${confnodes[3]}" "Client-1 (${Yellow}client-1${Reset})")"
    echo -e " 4) $(mainmenu_item "${confnodes[4]}" "Client-2 (${Yellow}client-2${Reset})")"
    echo -e " d) Done"
    read_opts
    for OPT in ${OPTIONS[@]}; do
      case "$OPT" in
        1)
          atoggle ${confnodes[$OPT]}
          confnodes[$OPT]=$?
          ;;
        2)
          atoggle ${confnodes[$OPT]}
          confnodes[$OPT]=$?
          ;;
        3)
          atoggle ${confnodes[$OPT]}
          confnodes[$OPT]=$?
          ;;
        4)
          atoggle ${confnodes[$OPT]}
          confnodes[$OPT]=$?
          ;;
        "d")
          nodeconvert
          return 0
          ;;
        *)
          invalid_option "Node Config Select $OPT"
          ;;
      esac
    done
    eliret
  done
}

nodeconvert() {
  nodes=()
  [[ ${confnodes[1]} -eq 0 ]] && nodes+=" ${gwi}"
  [[ ${confnodes[2]} -eq 0 ]] && nodes+=" ${srv}"
  [[ ${confnodes[3]} -eq 0 ]] && nodes+=" ${c1}"
  [[ ${confnodes[4]} -eq 0 ]] && nodes+=" ${c2}"
}
#echo "trace" ; pause
### EOF ###
