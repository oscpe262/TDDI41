#!/bin/bash
#[[ ! -f NETtest.sh ]] && echo -e "Missing dependency: NETtest.sh" && exit 1
#source NETtest.sh
### TESTS BRANCH ###############################################################

tests() {

  while true
  do
    print_title "Test Scripts by oscpe262 and matla782"
    echo -e "\n 0) $(mainmenu_item "${testlist[0]}" "Transfer files to nodes (${Yellow}Prereq.${Reset})")\n"

# Make dependent on node select
    echo " 1) $(mainmenu_item "${testlist[1]}" "Network test (${Yellow}NET${Reset})")"
    echo " 2) $(mainmenu_item "${testlist[2]}" "NTP Test (${Yellow}NET${Reset})")"
		echo " 3) $(mainmenu_item "${testlist[3]}" "RAID/LVM Test (${Yellow}STO${Reset})")"
		echo " 9) $(mainmenu_item "${testlist[9]}" "Local Script Development Test (${Red}DEV${Reset})")"
    echo " b) Back to Main Menu"
    read_opts
    for OPT in ${OPTIONS[@]}; do
      case "$OPT" in
        0)
          rsyncto testslist
          testlist[0]=$?
          ;;
        1)
          for target in ${nodes[@]}; do
            sshnet ${target} && testlist[1]=0 && continue
            testlist[1]=1 && break
          done
          ;;
        2)
          ntptest && testlist[2]=0 || testlist[2]=1
          pause
          ;;
        3)
          ssh -t root@${srv} ${remote_path}/STO_test.sh
          [[ $? == 0 ]] && testlist[3]=0 || testlist[3]=1
          pause
          ;;
				9)
					./NET_test.sh
          [[ $? == 0 ]] && testlist[4]=0 || testlist[4]=1
          pause
					;;
        "b")
          DRYRUN=1
					return 0
          ;;
        *)
          invalid_option "$OPT"
          ;;
      esac
    done
    eliret
  done
}

ntptest() {
  local ntplist=( 3 3 3 3 )
  inArray "${gwi}" "${nodes[@]}" && ntplist[0]=2
  inArray "${srv}" "${nodes[@]}" && ntplist[1]=2
  inArray "${c1}" "${nodes[@]}" && ntplist[2]=2
  inArray "${c2}" "${nodes[@]}" && ntplist[3]=2

  while true; do
    print_title "NTP Tests (NTP_test.sh) by oscpe262 and matla782"
    print_info "Testing NTP. This test might return false negatives if the nodes has not run for long enough to deviate from their NTP source."
    [[ ${ntplist[0]} -ne 3 ]] && echo "$(mainmenu_item "${ntplist[0]}" "Gateway")"
	  [[ ${ntplist[1]} -ne 3 ]] && echo "$(mainmenu_item "${ntplist[1]}" "Server")"
	  [[ ${ntplist[2]} -ne 3 ]] && echo "$(mainmenu_item "${ntplist[2]}" "Client-1")"
	  [[ ${ntplist[3]} -ne 3 ]] && echo "$(mainmenu_item "${ntplist[3]}" "Client-2")"
    prep_opts "${ntplist[@]}"
    [[ ! -z ${OPTION} ]] && read_opts "${OPTION}" || OPTIONS=("b")
    for OPT in ${OPTIONS[@]}; do
      case "$OPT" in
        0)
          sshntpt "${gwi}" && ntplist[$OPT]=0 || ntplist[$OPT]=1
          break
          ;;
        1)
          sshntpt "${srv}" && ntplist[$OPT]=0 || ntplist[$OPT]=1
          break
          ;;
        2)
          sshntpt "${c1}" && ntplist[$OPT]=0 || ntplist[$OPT]=1
          break
          ;;
        3)
          sshntpt "${c2}" && ntplist[$OPT]=0 || ntplist[$OPT]=1
          break
          ;;
        b)
          break
          ;;
        *)
          invalid_option "ntptest $OPT"
          break
          ;;
      esac
    done
  [[ $OPT == b ]] && break;
  done
  echo ""
  techo "${BOLD}NTP tests run complete.${Reset}"
  sleep 1
  inArray "1" "${ntplist[@]}" && return 1 || return 0
}

sshntpt() {
  techo "NTP status check (${Yellow}$1${Reset})"
  ssh -t root@${1} ${remote_path}/NTP_test.sh &> /dev/null &
  pid=$!; progress $pid
}

sshnet() {
  techo "NET status check (${Yellow}$1${Reset})"
  ssh -t root@${1} ${remote_path}/NET_test.sh && return 0 || return 1
}
### EOF ###
