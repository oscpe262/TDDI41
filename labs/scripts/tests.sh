#!/bin/bash
[[ ! -f NETtest.sh ]] && echo -e "Missing dependency: NETtest.sh" && exit 1
source NETtest.sh

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
