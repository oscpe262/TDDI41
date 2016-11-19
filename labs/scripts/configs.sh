#!/bin/bash
[[ ! -f SCT7.sh ]] && echo -e "Missing dependency: SCT7.sh" && exit 1
source SCT7.sh

### CONFIGS BRANCH #############################################################

# add node selections somewhere ...

configs() {

files=( "SCT7.sh" "SCT7_funcs.sh" "NTP_conf.sh" )
  while true
  do
    print_title "Configuration Scripts by oscpe262 and matla782"
    print_info "During a dry run, no permanent changes will be made to the system. Therefore, duplicate users in the infile can still be listed if not already present."
		echo -e "\n 0) $(mainmenu_item "${testlist[0]}" "Transfer files to nodes (${Yellow}Prereq.${Reset})")\n"

		echo " 1) $(mainmenu_item "${configlist[1]}" "Add users (${Yellow}SCT7${Reset}) ${Blue}Dry Run${Reset}")"
    echo " 2) $(mainmenu_item "${configlist[2]}" "Add users (${Yellow}SCT7${Reset}) ${BRed}Live Run${Reset}")"
    echo " b) Back to Main Menu"
    read_opts
    for OPT in ${OPTIONS[@]}; do
      case "$OPT" in
				0)
          scp DNS_srvconf.sh root@${srv}:${remote_path}
					transfer &
					pid=$! ; progress $pid
					configlist[0]=$?
					;;
        1)
          DRYRUN=1
          print_line
          read -p "Filepath to list of users on ${Yellow}local host${Reset}: " INFILE
#          [[ -z ${INFILE} ]] && INFILE="/home/splatrat/test/users"
# currently in progress ...
#					scp ${INFILE} root@${node}:${remote_path}
          #userscript "${INFILE}" && configlist[1]=1
          ;;
        2)
          DRYRUN=0
          read -p "Filepath to list of users: " INFILE
          [[ -z ${INFILE} ]] && INFILE="/home/splatrat/test/users2"
          userscript "${INFILE}" && configlist[2]=1
          ;;
        b)
          return
          ;;
        *)
          invalid_option "$OPT"
          ;;
      esac
    done
  done
}

### EOF ###
