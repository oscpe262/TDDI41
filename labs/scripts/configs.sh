#!/bin/bash
[[ ! -f SCT7.sh ]] && echo -e "Missing dependency: SCT7.sh" && exit 1
source SCT7.sh

configs() {
  while true
  do
    print_title "Configuration Scripts by oscpe262 and matla782"
    print_info "During a dry run, no permanent changes will be made to the system. Therefore, duplicate users can still be listed if not already present."
    echo " 1) $(mainmenu_item "${configlist[1]}" "Add users (${Yellow}SCT7${Reset}) ${Blue}Dry Run${Reset}")"
    echo " 2) $(mainmenu_item "${configlist[2]}" "Add users (${Yellow}SCT7${Reset}) ${BRed}Live Run${Reset}")"
    echo " b) Back to Main Menu"
    read_opts
    for OPT in ${OPTIONS[@]}; do
      case "$OPT" in
        1)
          DRYRUN=1
          print_line
          read -p "Filepath to list of users: " INFILE
          [[ -z ${INFILE} ]] && INFILE="/home/splatrat/test/users"
          userscript "${INFILE}" && configlist[1]=1
          ;;
        2)
          DRYRUN=0
          read -p "Filepath to list of users: " INFILE
          [[ -z ${INFILE} ]] && INFILE="/home/splatrat/test/users2"
          userscript "${INFILE}" && configlist[2]=1
          ;;
        "b")
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
