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
    print_title "Configuration Scripts by oscpe262 and matla782"
    print_info "During a dry run, no permanent changes will be made to the system. Therefore, duplicate users in the infile can still be listed if not already present."
    echo -e "\tWhere applicable, configuration will affect the following nodes ( b) to go back and change ):"
    echo -e "${BYellow}${_nodes}${Reset}"
		echo -e "\n 0) $(mainmenu_item "${configlist[0]}" "Transfer files to nodes (${Yellow}Prereq.${Reset})")\n"

		echo " 1) $(mainmenu_item "${configlist[1]}" "Add users (${Yellow}SCT7${Reset}) ${Blue}Dry Run${Reset}")"
    echo " 2) $(mainmenu_item "${configlist[2]}" "Add users (${Yellow}SCT7${Reset}) ${BRed}Live Run${Reset}")"
    echo " 3) $(mainmenu_item "${configlist[3]}" "DNS configuration (${Yellow}DNS${Reset})")"
    echo " 4) $(mainmenu_item "${configlist[4]}" "NTP configuration (${Yellow}NTP${Reset})")"
    echo " b) Back to Main Menu"
    read_opts
    for OPT in ${OPTIONS[@]}; do
      case "$OPT" in
				0)
          rsyncto conflist
					configlist[0]=$?
					;;
        1)
          DRYRUN=1
          print_line
          read -p "Filepath to list of users on ${Yellow}local host${Reset}: " INFILE
          [[ -z ${INFILE} ]] && INFILE="/home/splatrat/test/users"
          sshsct7
          configlist[$OPT]=$?
          files=(${_tmp[@]})
          ;;
        2)
          DRYRUN=0
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

sshntp() {
  for DEST in ${nodes[@]}; do
  techo "Configuring ${Blue}NTP${Reset} on node ${Yellow}${DEST}${Reset}"
    ssh -t root@${DEST} ${remote_path}/NTP_conf.sh
  done
}

sshdns() {
  for DEST in ${nodes[@]}; do
  techo "Configuring ${Blue}DNS${Reset} on node ${Yellow}${DEST}${Reset}"
    ssh -t root@${DEST} ${remote_path}/DNS_srvconf.sh
  done
}

sshsct7() {
  files=( "${INFILE}" )
    transfer &
    pid$! ; progress $pid
    for DEST in ${nodes[@]}; do
      ssh -t root@${DEST} ${remote_path}/SCT7.sh $(basename ${INFILE}) || return 1
    done
  return 0
}
#echo "trace" ; pause

### EOF ###
