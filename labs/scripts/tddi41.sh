#!/bin/bash
################################################################################
# TDDI41 2016 Main Script by oscpe262 and matla782
#
# This script is developed for TDDI41:b4 use. It has since been made dynamic,
# but have not been thoroughly tested for this purpose. No warranties - you are
# responsible for any consequence of not knowing what the script does.
# Using it wrong might kill your hamster.
# This script is somewhat inspired by oscpe262's revamp of helmuthdu's Arch
# Ultimate Install , which can be found at https://github.com/helmuthdu/aui .
################################################################################

### INCLUDE DEPENDENCIES #######################################################

[[ ! -f common.sh ]] && echo -e "Missing dependency: common.sh" && exit 1
[[ ! -f tests.sh ]] && echo -e "Missing dependency: tests.sh" && exit 1
[[ ! -f configs.sh ]] && echo -e "Missing dependency: configs.sh" && exit 1
source common.sh
source tests.sh
source configs.sh

### MAIN VARIABLES #############################################################

checklist=( 2 2 2 2 2 2 2 2 2 2 )
testlist=( 3 2 2 2 2 2 2 0 0 0 )
configlist=( 2 2 2 2 2 2 2 2 2 )
backuplist=( 0 2 2 )
maintitle="TDDI41 2016 Main Script"

### WELCOME ####################################################################

print_title "${maintitle}"
print_info "Welcome! Make sure you have read the documentation before you proceed!"
techo  "${Yellow}Prerequisites${Reset}"
ntecho ">> Environment set according to TDDI41 first four labs. (${Blue}https://www.ida.liu.se/~TDDI41/labs/index.en.shtml${Reset})"
echo -e "\t>> UML:s running, with SSH active and connectable."
echo -e "\t>> Script configured properly."
ntecho "Cancel at any time with ${Red}CTRL+C${Reset}."
pause

nodeconvert

### MAIN SUPPORT FUNCTION ######################################################
backups() {
  OPT=""
  while true; do
    print_select_title "UML Config Backup Scripts"
    echo " 1) $(mainmenu_item "${backuplist[1]}" "Backup Configs")"
    echo " 2) $(mainmenu_item "${backuplist[2]}" "Upload Backup Configs to UMLs")"
    echo -e "\n b) Back to Main Menu \n"
    read -rsn 1 -p "$prompt2" OPT
    case $OPT in
      1)
        print_title "Configuration Files Backup"
        rsyncfrom cfgfileslist
        backuplist[$OPT]=$?
        ;;
      2)
        print_title "Configuration Files Upload"
        rsynccfgto cfgfileslist
        backuplist[$OPT]=$?
        ;;
      "b")
        break
        ;;
      *)
        ;;
    esac
  done
  inArray "0" "${backuplist[@]}" && checklist[9]=0
  inArray "2" "${backuplist[@]}" && checklist[9]=2
  inArray "1" "${backuplist[@]}" && checklist[9]=1
}

### MAIN MENU ##################################################################

while true; do
  print_select_title "${maintitle}"
  ## Cascaded status levels
	inArray "0" "${configlist[@]}" && checklist[2]=0
  inArray "2" "${configlist[@]}" && checklist[2]=2
  inArray "1" "${configlist[@]}" && checklist[2]=1
	inArray "0" "${testlist[@]}" && checklist[3]=0
  inArray "2" "${testlist[@]}" && checklist[3]=2
  inArray "1" "${testlist[@]}" && checklist[3]=1
  if [[ ${testlist[0]} -eq 1 ]] || [[ ${configlist[0]} -eq 1 ]]; then
    checklist[6]=1
  else
    if [[ ${testlist[0]} -eq 0 ]] && [[ ${configlist[0]} -eq 0 ]]; then
      checklist[6]=0
    fi
  fi

  print_info "This script has two parts: ${Yellow}Tests${BReset} and ${BYellow}Configs${BReset}. ${Yellow}Tests${BReset} runs tests that are not covered in ${BYellow}Configs${BReset}, such as ${Blue}NET${BReset} configuration checks. ${BYellow}Configs${BReset} runs a series of scripts that configure the environment according to lab instructions."
  #print_info "Trace: gw:$gwi $gwe srv:$srv c1:$c1 c2:$c2" # debugging
  echo -e " 0) $(mainmenu_item "${checklist[0]}" "Change group (${Yellow}Beta${Reset})\n")"
  echo " 1) $(mainmenu_item "${checklist[1]}" "Node Selection")"
  echo " 2) $(mainmenu_item "${checklist[2]}" "Configs")"
  echo " 3) $(mainmenu_item "${checklist[3]}" "Tests")"
  echo " 4) $(mainmenu_item "${checklist[4]}" "Transfer Files to UMLs")"
  echo " 9) $(mainmenu_item "${checklist[9]}" "Backup Management")"
  echo -e "\n q) Quit\n"
  read_opts
  for OPT in ${OPTIONS[@]}; do
    case "$OPT" in
      0)
        dynassign
        ;;
      1)
        node_select
        ;;
      2)
        configs
        ;;
      3)
        tests
        ;;
      4)
        print_title "Remote Scripts Sync"
        rsyncto testslist conflist
        setval=$?
        [[ $setval -ge 1 ]] && setval=1
        testlist[0]=$setval
			  configlist[0]=$setval
        ;;
      9)
        backups
        ;;
      "q")
        #[[ -f nodes.conf ]] && rm nodes.conf
        exit 0
        ;;
      *)
        invalid_option "$OPT"
        ;;
    esac
  done
done


### EOF ###
