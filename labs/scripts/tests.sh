#!/bin/bash
#[[ ! -f NETtest.sh ]] && echo -e "Missing dependency: NETtest.sh" && exit 1
#source NETtest.sh
### TESTS BRANCH ###############################################################

tests() {

  while true
  do
    print_select_title "Test Scripts"
    echo -e "\n 0) $(mainmenu_item "${testlist[0]}" "Transfer files to nodes (${Yellow}Prereq.${Reset})")\n"

# Make dependent on node select
    echo " 1) $(mainmenu_item "${testlist[1]}" "Network test (${Yellow}NET${Reset})")"
    echo " 2) $(mainmenu_item "${testlist[2]}" "DNS test (${Yellow}DNS${Reset})")"
    echo " 3) $(mainmenu_item "${testlist[3]}" "NTP Test (${Yellow}NTP${Reset})")"
    echo " 4) $(mainmenu_item "${testlist[4]}" "NIS Test (${Yellow}NIS${Reset})")"
		echo " 5) $(mainmenu_item "${testlist[5]}" "RAID/LVM Test (${Yellow}STO${Reset})")"
    echo " 6) $(mainmenu_item "${testlist[6]}" "NFS Test (${Yellow}NFS${Reset})")"
		echo " 9) $(mainmenu_item "${testlist[9]}" "Local Script Development Test (${Red}DEV${Reset})")"
    echo " b) Back to Main Menu"
    read_opts
    for OPT in ${OPTIONS[@]}; do
      setval=0
      case "$OPT" in
        0)
          print_title "Remote Test Files Syncronization"
          rsyncto testslist
          testlist[0]=$?
          ;;
        1)
          print_title "NET Test Suite"
          print_info "Performing a set of network tests from selected nodes, making sure ${BYellow}NET${BReset} lab has been set up properly."
          for target in ${nodes[@]}; do
            sshnet ${target} || setval=1
          done
          testlist[1]=$setval
          ;;
        2)
          print_title "DNS Test Suite"
          print_info "Testing DNS. Further description TBA."
          dnstest
          [[ $? == 0 ]] && testlist[2]=0 || testlist[2]=1
          sleep 1
          ;;
        3)
          print_title "NTP Test Suite"
          print_info "Testing NTP. This test might return ${Yellow}false negatives${Reset} if the nodes has not run for long enough to deviate from their NTP source."
          for target in ${nodes[@]}; do
            ntptest ${target} || setval=1
          done
          testlist[3]=$setval
          sleep 1
          ;;
        4)
          echo "TBA"
          ;;
        5)
          print_title "STO Test Suite"
          print_info "Testing storage configuration. We check if the RAID array, Virtual Group and Logical Volume can be found in ${Blue}/dev${BReset}."
          techo "Connecting, please wait"
          ssh -t root@${srv} ${remote_path}/STO_test.sh
          [[ $? == 0 ]] && testlist[5]=0 || testlist[5]=1
          sleep 1
          ;;
        6)
          echo "TBA"
          ;;
				9)
					./NET_test.sh
          [[ $? == 0 ]] && testlist[9]=0 || testlist[9]=1
          sleep 1
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

dnstest() {
  #techo "Annotate me omg!"
  ./DNS_test.sh
}

ntptest() {
  techo "NTP status check (${Yellow}${1}${Reset})"
  ssh -t root@${1} ${remote_path}/NTP_test.sh &> /dev/null &
  pid=$!; progress $pid
}

sshnet() {
  ntecho "NET status check (${Yellow}$1${Reset})"
  ssh -t root@${1} ${remote_path}/NET_test.sh && return 0 || return 1
}
### EOF ###
