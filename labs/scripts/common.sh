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

  LOG="/dev/null"
  #LOG="`basename ${0}`.log"
  #[[ -f $LOG ]] && rm -f $LOG


  nodenames=( "gw" "server" "client-1" "client-2" )
  confnodes=( 0 2 0 2 2 )
  dynarray=( 0 0 0 0 0 0 0 )


  tboxl="${BBlue}[${Reset}"
  tboxr="${BBlue}]${Reset}"
  tdone="${tboxl}${Green} ok ${tboxr}"
  tfail="${tboxl}${Red}fail${tboxr}"
  ttodo="${tboxl}${Reset} -- ${tboxr}"
  legend="${tdone} = Passed, ${tfail} = Failed, ${ttodo} = Not yet run"

  remote_path="/root"
  files=()
  SPIN="/-\|"
  prompt1="Enter options (e.g: 1 2 3 or 1-3): "
  #prompt3="You have to manually enter the following commands, then press ${BYellow}ctrl+d${Reset} or type ${BYellow}exit${Reset}:"

### SUPPORT FUNCS ##############################################################

cecho () {
  echo "Deprecated function, cecho."
  echo -e "$1" && echo -e "$1" >> "$LOG"
  tput sgr0
}
ncecho () {
  echo "Deprecated function, ncecho."
  echo -ne "$1" && echo -ne "$1" >> "$LOG"
  tput sgr0
}

ntecho () {
  echo -e "\n\n\t${1}"
}

spinny() {
  echo -ne "\b${SPIN:i++%${#SPIN}:1}"
}

techo() {
  local _line="${1}:  "
  printf "\n%s" "    ${_line}"
  [[ $(tput cols) -ge 120 ]] && printf "%*s" $(( 60-${#_line} )) ""
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
#      echo -ne "$pid's retcode: $retcode " >> $LOG
      #[[ $DRYRUN -eq 1 ]] && dry_ok && return 0
      if [[ $retcode == 0 ]] || [[ $retcode == 255 ]]; then
        tested_ok "Passed!"
				return 0
      else
        error_msg "Failed! ($retcode)"
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

print_select_title() {
  tput clear
  local _title="${BYellow}${1} by oscpe262 and matla782${Reset}"
  print_line "#" "${BBlue}"
  printf "%*s\n" $(( (${#_title} + $(tput cols)) / 2)) "${_title}"
  print_line "#" ${BBlue}
  ntecho "${legend}"
  echo ""
}

print_title() {
  tput clear
  local _title="${BYellow}${1} by oscpe262 and matla782${Reset}"
  print_line "#" "${BBlue}"
  printf "%*s\n" $(( (${#_title} + $(tput cols)) / 2)) "${_title}"
  print_line "#" ${BBlue}
  ntecho ""
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
  read -rsn1 -p"Press any key to continue "
}

checkbox() {
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

nodebox() {
  #echo -e "fpp $1"
  [[ $1 -eq 0 ]] && echo -e "${ttodo}"
  [[ $1 -eq 1 ]] && echo -e "${tboxl} ${Yellow}gw${Reset} ${tboxr}"
  [[ $1 -eq 2 ]] && echo -e "${tboxl} ${Yellow}sr${Reset} ${tboxr}"
  [[ $1 -eq 3 ]] && echo -e "${tboxl} ${Yellow}c1${Reset} ${tboxr}"
  [[ $1 -eq 4 ]] && echo -e "${tboxl} ${Yellow}c2${Reset} ${tboxr}"
}

dynmenu_item() {
  #if the task is done make sure we get the state
  if [[ $1 == 1 ]] &&  [[ "$3" != "" ]]; then
    state="${BGreen}[${Reset}$3${BGreen}]${Reset}"
  fi
  echo -e "$(nodebox "$1") ${Bold}$2${Reset} ${state}"
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
    ntecho "Downloading files from ${Yellow}${srca}${Reset} (${Yellow}$SRC${Reset}):"
      while read FILE; do
        [[ ! $SRC == "GW" ]] && [[ $FILE == *"quagga"* ]] && continue
        [[ ! $SRC == "SRV" ]] && [[ $FILE == *"bind"* ]] && continue
        techo "${FILE}"
        rsync -aruz -e "ssh" root@${srca}:${FILE} `pwd`/../configs/$SRC${FILE} &> /dev/null &
        pid=$!; progress $pid
        [[ ! $? == 0 ]] && retval=1
      done < ${INFILE}
      echo ""
    done
  return ${retval}
}

rsynccfgto() {
  local INFILE=$1
  local retval=0
  for srca in ${nodes[@]}; do
    [[ $srca == ${gwi} ]] && SRC="GW"
    [[ $srca == ${srv} ]] && SRC="SRV"
    [[ $srca == ${c1} ]] && SRC="CL1"
    [[ $srca == ${c2} ]] && SRC="CL2"
    ntecho "Uploading files to ${Yellow}${srca}${Reset} (${Yellow}$SRC${Reset}):"
      while read FILE; do
        [[ ! $SRC == "GW" ]] && [[ $FILE == *"quagga"* ]] && continue
        [[ ! $SRC == "SRV" ]] && [[ $FILE == *"bind"* ]] && continue
        techo "${FILE}"
        rsync -aruz -e "ssh" `pwd`/../configs/$SRC${FILE} root@${srca}:${FILE} &> /dev/null &
        pid=$!; progress $pid
        [[ ! $? == 0 ]] && retval=1
      done < ${INFILE}
      echo ""
    done
  return ${retval}
}

rsyncto(){
  local retval=0
  local FILES=""
  FILES+="-T $1 "
  [[ ! -z $2 ]] && FILES+="-T $2"
  print_info "Configurations and some tests need to be made on the UMLs. To make this efficient, we prime the nodes with the scripts needed, and run them remotely. This might take a while, but needs only to be done when the remotely run scripts are updated."
  techo "Packing files"
  tar -cf transfer.tar ${FILES} &
  pid=$!; progress $pid
  for srca in ${nodes[@]}; do
    ntecho "Syncing files to ${Yellow}${srca}${Reset}:"
    techo "Transferring"
    rsync -aruz -e "ssh" transfer.tar root@${srca}:${remote_path}/ &> /dev/null &
    pid=$!; progress $pid
    [[ ! $? == 0 ]] && retval=1
    techo "Unpacking"
    ssh -t root@${srca} tar -xf transfer.tar &> /dev/null &
    pid=$!; progress $pid
    [[ ! $? == 0 ]] && retval=1
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
  while true; do
    print_title "Node Configuration Selection"
    print_info "${Yellow}Toggle${BReset} nodes to be configured and tested (default = all). Nodes can be reselected between configurations if desired. Some tests and configurations are bound to certain nodes and will override this selection."
    echo -e "\n 1) $(mainmenu_item "${confnodes[1]}" "Gateway (${Yellow}gw${Reset})")"
    echo -e " 2) $(mainmenu_item "${confnodes[2]}" "Server (${Yellow}server${Reset})")"
    echo -e " 3) $(mainmenu_item "${confnodes[3]}" "Client-1 (${Yellow}client-1${Reset})")"
    echo -e " 4) $(mainmenu_item "${confnodes[4]}" "Client-2 (${Yellow}client-2${Reset})")"
    echo -e "\n d) Done\n\n"
    read -rsn 1 OPT
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
}

dynassign() {
  # To solve: remove statics, init on launch, avoid common.sh-sourcing collisions.
  print_select_title "Dynamic Script Config"
  print_info "Meep"
  local _grp
  [[ ! -z $1 ]] && _grp="$(cat nodes.conf)" || read -p "Group number:" _grp
  local _ip
  GROUP="$(echo $_grp | tr 'A-F' 'a-f')"
  DDNAME="${GROUP}.sysinst.ida.liu.se"
  local _ENTRY="$(cat NETWORKS | grep ${DDNAME})"
  STARTADDRESS="$(echo ${_ENTRY} | awk '{print $3}' | sed 's/\/..// ; s/.*\.//' )"
  nw="130.236$(echo ${_ENTRY} | awk '{print $3}' | sed 's/\/..// ; s/.*236//' | cut -c 1-4 )" #$nw
  EXTIF="$(echo ${_ENTRY} | awk '{print $4}')"

  IPRANGE=()
  for _ip in {1..6}; do
    IPRANGE+=("$nw.$(($STARTADDRESS + $_ip)) ")
  done
  [[ ! -z $1 ]] && gw=${IPRANGE[0]} && srv=${IPRANGE[1]} && c1=${IPRANGE[2]} && c2=${IPRANGE[3]} && return 0
  local dnodes=( "Gateway/Router" "Server" "Client-1" "Client-2" )
  local it=0

  while true; do
    print_select_title "Dynamic Script Config"
    print_info "Meep"
    echo -e " 1) $(dynmenu_item "${dynarray[1]}" "${IPRANGE[0]}")"
    echo -e " 2) $(dynmenu_item "${dynarray[2]}" "${IPRANGE[1]}")"
    echo -e " 3) $(dynmenu_item "${dynarray[3]}" "${IPRANGE[2]}")"
    echo -e " 4) $(dynmenu_item "${dynarray[4]}" "${IPRANGE[3]}")"
    echo -e " 5) $(dynmenu_item "${dynarray[5]}" "${IPRANGE[4]}")"
    echo -e " 6) $(dynmenu_item "${dynarray[6]}" "${IPRANGE[5]}")"
    echo ""
    [[ $it == 4 ]] && break;
    read -rsn 1 -p "Assign ${dnodes[$it]} an IP address " OPTION
    case "$OPTION" in
      [1-6])
        [[ ${dynarray[$OPTION]} -ne 0 ]] && continue
        dynarray[$OPTION]=$(($it+1))
        ;;
      *)
        continue
        ;;
    esac
    #echo $it ${IPRANGE[$(($OPTION - 1))]}
    [[ $it == 0 ]] && gw="${IPRANGE[$(($OPTION - 1))]}"
    [[ $it == 1 ]] && srv="${IPRANGE[$(($OPTION - 1))]}"
    [[ $it == 2 ]] && c1="${IPRANGE[$(($OPTION - 1))]}"
    [[ $it == 3 ]] && c2="${IPRANGE[$(($OPTION - 1))]}"
    ((it++))
  done
  echo -e "$GROUP" > nodes.conf
  pause
}

nodeconvert() {
  nodes=()
  [[ ${confnodes[1]} -eq 0 ]] && nodes+=" ${gwi}"
  [[ ${confnodes[2]} -eq 0 ]] && nodes+=" ${srv}"
  [[ ${confnodes[3]} -eq 0 ]] && nodes+=" ${c1}"
  [[ ${confnodes[4]} -eq 0 ]] && nodes+=" ${c2}"
}

[[ -f nodes.conf ]] && dynassign "`cat nodes.conf`" || dynassign "b4"
  #nw=130.236.178
  gwe=${nw}.17
  #gwi=${nw}.153
  #srv=${nw}.154
  #c1=${nw}.155
  #c2=${nw}.156

#echo "trace" ; pause
### EOF ###
