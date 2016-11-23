#!/bin/bash
#[[ ! -f NET_funcs.sh ]] && echo -e "Missing dependency: NET_funcs.sh" && exit 1
#source NET_funcs.sh
source common.sh


### NET TEST MAIN FUNCTION #####################################################
test_net() {
  local HOST="`uname -n`"
  local ntlist=( 3 2 2 2 2 2 2 2 2 2 )

  [[ $HOST == "client-2" ]] && ntlist[2]=0
  [[ $HOST == "client-1" ]] && ntlist[3]=0
  [[ $HOST == "gw" ]] && ntlist[5]=0 && ntlist[6]=0
  [[ $HOST == "server" ]] && ntlist[4]=0

  while true; do
	print_title "NET Tests (NETtest.sh) by oscpe262 and matla782"
	print_info "Tests for NET, currently on $HOST"
	#[[ ${ntlist[1]} -ne 3 ]] && echo "$(mainmenu_item "${ntlist[1]}" "Hostname set to (${Yellow}${HOST}${Reset})")"
	#[[ ${ntlist[2]} -ne 3 ]] && echo "$(mainmenu_item "${ntlist[2]}" "Ping ${Yellow}${c2}${Reset} (Client-2 Internal, IP)")"
	#[[ ${ntlist[3]} -ne 3 ]] && echo "$(mainmenu_item "${ntlist[3]}" "Ping ${Yellow}${c1}${Reset} (Client-1 Internal, IP)")"
	#[[ ${ntlist[4]} -ne 3 ]] && echo "$(mainmenu_item "${ntlist[4]}" "Ping ${Yellow}${srv}${Reset} (Server Internal, IP)")"
	#[[ ${ntlist[5]} -ne 3 ]] && echo "$(mainmenu_item "${ntlist[5]}" "Ping ${Yellow}${gwi}${Reset} (Gateway Internal, IP)")"
	#[[ ${ntlist[6]} -ne 3 ]] && echo "$(mainmenu_item "${ntlist[6]}" "Ping ${Yellow}${gwe}${Reset} (Gateway External, IP)")"
	#[[ ${ntlist[7]} -ne 3 ]] && echo "$(mainmenu_item "${ntlist[7]}" "Ping ${Yellow}${nw}.1${Reset} (ida-gw, IP)")"
	#[[ ${ntlist[8]} -ne 3 ]] && echo "$(mainmenu_item "${ntlist[8]}" "Ping ${Yellow}ida-gw.sysinst.ida.liu.se${Reset} (ida-gw, name-resolved)")"
	#[[ ${ntlist[9]} -ne 3 ]] && echo "$(mainmenu_item "${ntlist[9]}" "Ping ${Yellow}www.google.com${Reset} (World-Wide Connectivity)")"
	echo "$(mainmenu_item "${ntlist[1]}" "Hostname set to (${Yellow}${HOST}${Reset})")"
	echo "$(mainmenu_item "${ntlist[2]}" "Ping ${Yellow}${c2}${Reset} (Client-2 Internal, IP)")"
	echo "$(mainmenu_item "${ntlist[3]}" "Ping ${Yellow}${c1}${Reset} (Client-1 Internal, IP)")"
	echo "$(mainmenu_item "${ntlist[4]}" "Ping ${Yellow}${srv}${Reset} (Server Internal, IP)")"
	echo "$(mainmenu_item "${ntlist[5]}" "Ping ${Yellow}${gwi}${Reset} (Gateway Internal, IP)")"
	echo "$(mainmenu_item "${ntlist[6]}" "Ping ${Yellow}${gwe}${Reset} (Gateway External, IP)")"
	echo "$(mainmenu_item "${ntlist[7]}" "Ping ${Yellow}${nw}.1${Reset} (ida-gw, IP)")"
	echo "$(mainmenu_item "${ntlist[8]}" "Ping ${Yellow}ida-gw.sysinst.ida.liu.se${Reset} (ida-gw, name-resolved)")"
	echo "$(mainmenu_item "${ntlist[9]}" "Ping ${Yellow}www.google.com${Reset} (World-Wide Connectivity)")"
	prep_opts "${ntlist[@]}"
	[[ ! -z ${OPTION} ]] && read_opts "${OPTION}" || OPTIONS=("b")
	for OPT in ${OPTIONS[@]}; do
    case "$OPT" in
  		1)
  		    check_hostname $HOST && ntlist[$OPT]=0 || ntlist[$OPT]=1
  		    break
  		    ;;
  		2)
  		    ping_test "${c2}" && ntlist[$OPT]=0 || ntlist[$OPT]=1
  		    break
  		    ;;
  		3)
  		    ping_test "${c1}" && ntlist[$OPT]=0 || ntlist[$OPT]=1
  		    break
  		    ;;
  		4)
  		    ping_test "${srv}" && ntlist[$OPT]=0 || ntlist[$OPT]=1
  		    break
  		    ;;
  		5)
  		    ping_test "${gwi}" && ntlist[$OPT]=0 || ntlist[$OPT]=1
  		    break
  		    ;;
  		6)
  		    ping_test "${gwe}" && ntlist[$OPT]=0 || ntlist[$OPT]=1
  		    break
  		    ;;
  		7)
  		    ping_test "${nw}.1" && ntlist[$OPT]=0 || ntlist[$OPT]=1
  		    break
  		    ;;
  		8)
  		    ping_test "ida-gw.sysinst.ida.liu.se" && ntlist[$OPT]=0 || ntlist[$OPT]=1
  		    break
  		    ;;
  		9)
  		    ping_test "www.google.com" && ntlist[$OPT]=0 || ntlist[$OPT]=1
  		    break
  		    ;;
  		b)
  		    break
  		    ;;
  		*)
  		    invalid_option "NETtest.sh: ${OPT}"
  		    break
  		    ;;
      esac
    done
    [[ $OPT == b ]] && break;
  done
  echo ""
  techo "${BOLD}NET tests run complete.${Reset}"
  sleep 1
  inArray "1" "${ntlist[@]}" && return 1 || return 0
}

ping_test () {
defpingc=3 #default amount of ping tries
#ping target_ip [ping count]
  local _target="$1"
  local _count=""
  [[ -z $2 ]] && _count=$defpingc || _count=$2
  if [[ $VERBOSE -eq 1 ]]; then
    ping -c ${_count} ${_target}
  else
		techo "Ping ${Yellow}${_target}${Reset}"
		ping -c ${_count} ${_target} &> /dev/null &
    pid=$!; progress $pid
  fi
}

check_hostname () {
	techo "Hostname set to (${Yellow}$1${Reset})"
  [[ `uname -n` == $1 ]] &
    pid=$!; progress $pid
}

test_net


### EOF ###
