#!/bin/bash

### CONFIGS BRANCH #############################################################

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
    echo -e "\tWhere applicable, configuration will affect the following nodes ( b) to go back and change ):"
    echo -e "${BYellow}${_nodes}${Reset}"
		echo -e "\n 0) $(mainmenu_item "${configlist[0]}" "Transfer Files to UMLs (${Yellow}Prereq.${Reset})")\n"
    echo " 1) $(mainmenu_item "${configlist[1]}" "Install all packages (${Red}DEV${Reset})")"
    echo " 2) $(mainmenu_item "${configlist[2]}" "Add Users (${Yellow}SCT7${Reset})")"
    echo " 3) $(mainmenu_item "${configlist[3]}" "DNS Configuration (${Yellow}DNS${Reset})")"
    echo " 4) $(mainmenu_item "${configlist[4]}" "NTP Configuration (${Yellow}NTP${Reset})")"
    echo " 5) $(mainmenu_item "${configlist[5]}" "Storage Configuration (SRV only) (${Yellow}STO${Reset})")"
    echo " 6) $(mainmenu_item "${configlist[6]}" "Storage Undo Configs (SRV only) (${Yellow}STO${Reset})")"
    echo " 7) $(mainmenu_item "${configlist[7]}" "NIS Configs (${Yellow}NIS${Reset})")"
    echo " 8) $(mainmenu_item "${configlist[8]}" "NFS Configs (${Yellow}NFS${Reset})")"
    echo -e "\n b) Back to Main Menu\n"
    read_opts
    for OPT in ${OPTIONS[@]}; do
      case "$OPT" in
				0)
          csync
					;;
        1)
          for DEST in ${nodes[@]}; do
            techo "Installing packages${Blue}${Reset} on node ${Yellow}${DEST}${Reset}"
            ssh -t root@${DEST} ${remote_path}/installpkgs.sh || configlist[1]=1
          done
          ;;
        2)
          print_line
          read -p "Filepath to list of users: " INFILE
          [[ -z ${INFILE} ]] && INFILE="/home/splatrat/test/users"
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
        7)
          sshnis &
          pid=$! ; progress $pid
          configlist[$OPT]=$?
          ;;
        8)
          sshnfs &
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

sshnfs() {
  local _retval=0
  print_title "NFS Setup Script"
  print_info "This will configure NFS-shares on the nodes. This set of script depends on NIS and STO to be configured first."
  for DEST in ${nodes[@]}; do
    techo "Configuring ${Blue}NFS${Reset} on node ${Yellow}${DEST}${Reset}"
    ssh -t root@${DEST} ${remote_path}/NFS_conf.sh &> /dev/null &
    pid=$! ; progress $pid
    [[ $? -ne 0 ]] && ((_retval++))
  done
  sleep 3
  [[ $_retval -ne 0 ]] && return 1 || return 0
}

sshnis() {
  local _retval=0
  print_title "NIS Setup Script"
  print_info "Installing and configuring NIS and updates its maps."
  for DEST in ${nodes[@]}; do
    techo "Configuring ${Blue}NIS${Reset} on node ${Yellow}${DEST}${Reset}"
    ssh -t root@${DEST} ${remote_path}/NIS_conf.sh &> /dev/null &
    pid=$! ; progress $pid
    [[ $? -ne 0 ]] && ((_retval++))
  done
  sleep 3
  [[ $_retval -ne 0 ]] && return 1 || return 0
}

csync() {
  print_title "Remote Configuration Script Files Syncronization"
  print_info "Updating configuration scripts on remote hosts."
  rsyncto conflist
	configlist[0]=$?
}

sshsto() {
  local _retval
  print_title "RAID and LVM Setup Script"
  print_info "Currently configuring a RAID 1 array and an LVM setup on the server."
  techo "Configuring ${Blue}STO${Reset} on node ${Yellow}${srv}${Reset}"
  ssh -t root@${srv} ${remote_path}/STO_conf.sh $1 &> /dev/null &
  pid=$! ; progress $pid
  retval=$?
  sleep 1
  return $_retval
}

sshntp() {
  local _retval=0
  print_title "NTP Configuration Script"
  print_info "Currently configuring the UMLs to sync their time through NTP."
  for DEST in ${nodes[@]}; do
  techo "Configuring ${Blue}NTP${Reset} on node ${Yellow}${DEST}${Reset}"
    ssh -t root@${DEST} ${remote_path}/NTP_conf.sh &> /dev/null &
    pid=$! ; progress $pid
    [[ $? -ne 0 ]] && ((_retval++))
  done
  sleep 1
  [[ $_retval -ne 0 ]] && return 1 || return 0
}

sshdns() {
  local _retval=0
  print_title "DNS Configuration Script"
  print_info "Currently configuring the server to be the internal network's name server, and the other nodes to use it accordingly."
  for DEST in ${nodes[@]}; do
  techo "Configuring ${Blue}DNS${Reset} on node ${Yellow}${DEST}${Reset}"
    ssh -t root@${DEST} ${remote_path}/DNS_conf.sh &> /dev/null &
    pid=$! ; progress $pid
    [[ $? -ne 0 ]] && ((_retval++))
  done
  sleep 1
  [[ $_retval -ne 0 ]] && return 1 || return 0
}

sshsct7() {
  scp ${INFILE} root@${srv}:/root/users &#> /dev/null &
  pid=$! ; progress $pid
  [[ $? -ne 0 ]] && ((_retval++))
  pause
  ssh -t root@${srv} ${remote_path}/SCT7.sh
  pid=$! ; progress $pid
  [[ $? -ne 0 ]] && ((_retval++))
  return $retval
}

### EOF ###
