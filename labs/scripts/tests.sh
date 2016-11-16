#!/bin/bash
[[ ! -f NETtest.sh ]] && echo -e "Missing dependency: NETtest.sh" && exit 1
source NETtest.sh
### TESTS BRANCH ###############################################################

tests() {

  DRYRUN=0
  files=( "NETtest.sh" "NET_funcs.sh" "common.sh" "remotetest.sh")

  while true
  do
    print_title "Test Scripts by oscpe262 and matla782"
    echo -e "\n 0) $(mainmenu_item "${testlist[0]}" "Transfer files to nodes (${Yellow}Prereq.${Reset})")\n"
		
    echo " 1) $(mainmenu_item "${testlist[1]}" "Network test gw (${Yellow}NET${Reset})")"
    echo " 2) $(mainmenu_item "${testlist[2]}" "Network test server (${Yellow}NET${Reset})")"
    echo " 3) $(mainmenu_item "${testlist[3]}" "Network test client-1 (${Yellow}NET${Reset})")"
    echo " 4) $(mainmenu_item "${testlist[4]}" "Network test client-2 (${Yellow}NET${Reset})")"
		echo " 9) $(mainmenu_item "${testlist[9]}" "Local Script Development Test (${Red}DEV${Reset})")"
    echo " b) Back to Main Menu"
    read_opts
    for OPT in ${OPTIONS[@]}; do
      case "$OPT" in
        0)
          transfer &
          pid=$! ; progress $pid
          testlist[0]=$?
          ;;
        1)
          ssh -t root@${gwi} ${remote_path}/remotetest.sh gw NET
          testlist[1]=$?
          ;;
        2)
          ssh -t root@${srv} ${remote_path}/remotetest.sh server NET
          testlist[2]=$?
          ;;
        3)
          ssh -t root@${c1} ${remote_path}/remotetest.sh client-1 NET
          testlist[3]=$?
          ;;
        4)
          ssh -t root@${c2} ${remote_path}/remotetest.sh client-2 NET
          testlist[4]=$?
          ;;
				9)
					./remotetest.sh betelgeuse NET
					testlist[9]=$?
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

### EOF ###
