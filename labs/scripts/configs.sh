#!/bin/bash

### CONFIGS BRANCH #############################################################

# add node selections somewhere ...

configs() {
  local _nodes="\t"
  [[ ${confnodes[1]} -eq 0 ]] && _nodes+="Gateway, "
  [[ ${confnodes[2]} -eq 0 ]] && _nodes+="Server, "
  [[ ${confnodes[3]} -eq 0 ]] && _nodes+="Client-1, "
  [[ ${confnodes[4]} -eq 0 ]] && _nodes+="Client-2, "
  _nodes=${_nodes::-2}
  files=( "SCT7.sh" "SCT7_funcs.sh" "NTP_conf.sh" "DNS_srvconf.sh" "common.sh" )
  local _tmp=("${files[@]}")
  while true
  do
    print_select_title "Configuration Scripts"
    print_info "During a dry run, no permanent changes will be made to the system. Therefore, duplicate users in the infile can still be listed if not already present."
    echo -e "\tWhere applicable, configuration will affect the following nodes ( b) to go back and change ):"
    echo -e "${BYellow}${_nodes}${Reset}"
		echo -e "\n 0) $(mainmenu_item "${configlist[0]}" "Transfer files to nodes (${Yellow}Prereq.${Reset})")\n"

		echo " 1) $(mainmenu_item "${configlist[1]}" "Add users (${Yellow}SCT7${Reset}) ${Blue}Dry Run${Reset} Not yet implemented")"
    echo " 2) $(mainmenu_item "${configlist[2]}" "Add users (${Yellow}SCT7${Reset}) ${BRed}Live Run${Reset} Not yet implemented")"
    echo " 3) $(mainmenu_item "${configlist[3]}" "DNS configuration (${Yellow}DNS${Reset})")"
    echo " 4) $(mainmenu_item "${configlist[4]}" "NTP configuration (${Yellow}NTP${Reset})")"
    echo " 5) $(mainmenu_item "${configlist[5]}" "Storage configuration (SRV only) (${Yellow}STO${Reset})")"
    echo " 6) $(mainmenu_item "${configlist[6]}" "Storage undo configs (SRV only) (${Yellow}STO${Reset})")"
    echo " b) Back to Main Menu"
    read_opts
    for OPT in ${OPTIONS[@]}; do
      case "$OPT" in
				0)
          csync
					;;
        1)
          break
          print_line
          read -p "Filepath to list of users on ${Yellow}local host${Reset}: " INFILE
          [[ -z ${INFILE} ]] && INFILE="/home/splatrat/test/users"
          sshsct7 "dry"
          configlist[$OPT]=$?
          files=(${_tmp[@]})
          ;;
        2)
          break
          print_line
          read -p "Filepath to list of users: " INFILE
          [[ -z ${INFILE} ]] && INFILE="/home/splatrat/test/users2"
          userscript "${INFILE}"
          sshsct7
          configlist[$OPT]=$?
          files=(${_tmp[@]})
          ;;
        3)
          sshdns &
          pid=$! ; progress $pid
          configlist[$OPT]=$?
          ;;
        4)
          sshntp &
          pid=$! ; progress $pid
          configlist[$OPT]=$?
          ;;
        5)
          sshsto &
          pid=$! ; progress $pid
          configlist[$OPT]=$?
          ;;
        6)
          sshsto erase &
          pid=$! ; progress $pid
          configlist[$OPT]=$?
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

csync() {
  print_title "Remote Configuration Script Files Syncronization"
  rsyncto conflist
	configlist[0]=$?
}

sshsto() {
  techo "Configuring ${Blue}STO${Reset} on node ${Yellow}${srv}${Reset}"
  ssh -t root@${srv} ${remote_path}/STO_conf.sh $1 &> /dev/null &
  pid=$! ; progress $pid
}

sshntp() {
  for DEST in ${nodes[@]}; do
  techo "Configuring ${Blue}NTP${Reset} on node ${Yellow}${DEST}${Reset}"
    ssh -t root@${DEST} ${remote_path}/NTP_conf.sh
  done
}

sshdns() {
  for DEST in ${nodes[@]}; do
  techo "Configuring ${Blue}DNS${Reset} on node ${Yellow}${DEST}${Reset}"
    ssh -t root@${DEST} ${remote_path}/DNS_conf.sh
  done
}

sshsct7() {
  local _arg2=""
  [[ $1 == "dry" ]] && DRYRUN=1 && _arg2="dry" || DRYRUN=0
  files=( "${INFILE}" )
    transfer &
    pid$! ; progress $pid
    for DEST in ${nodes[@]}; do
      ssh -t root@${DEST} ${remote_path}/SCT7.sh $(basename ${INFILE}) ${arg2} || return 1
    done
  return 0
}
#echo "trace" ; pause

### EOF ###
