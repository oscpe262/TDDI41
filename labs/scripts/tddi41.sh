#!/bin/bash
################################################################################
# TDDI41 2016 Main Script by oscpe262 and matla782
#
# This script is for TDDI41:b4 use only. No warranties - you are responsible for
# any consequence of not knowing what it does.
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

checklist=( 2 2 2 2 2 2 )
testlist=( 3 2 2 2 0 2 0 0 0 2 )
configlist=( 2 2 2 2 2 2 2 2 2)
maintitle="TDDI41 2016 Main Script"

### WELCOME ####################################################################

print_title "${maintitle}"
print_info "Welcome! Make sure you have read the documentation before you proceed!"
echo -e "Prerequisites:\n"
echo ">> Environment set according to TDDI41 first four labs."
echo ">> UML:s running, with SSH active and connectable."
echo -e ">> Configurated this set of scripts.\n"
print_line
echo -e "Cancel at any time with CTRL+C.\n"
#pause

nodeconvert

### MAIN MENU ##################################################################

while true; do
  print_select_title "${maintitle}"
	inArray "0" "${configlist[@]}" && checklist[2]=0
  inArray "2" "${configlist[@]}" && checklist[2]=2
  inArray "1" "${configlist[@]}" && checklist[2]=1
	inArray "0" "${testlist[@]}" && checklist[3]=0
  inArray "2" "${testlist[@]}" && checklist[3]=2
  inArray "1" "${testlist[@]}" && checklist[3]=1
  if [[ ${testlist[0]} -eq 1 ]] || [[ ${configlist[0]} -eq 1 ]]; then
    checklist[5]=1
  else
    if [[ ${testlist[0]} -eq 0 ]] && [[ ${configlist[0]} -eq 0 ]]; then
      checklist[5]=0
    fi
  fi
  print_info "This script has two parts: ${Yellow}Tests${BReset} and ${BYellow}Configs${BReset}. ${Yellow}Tests${BReset} runs tests that are not covered in ${BYellow}Configs${BReset}, such as ${Blue}NET${BReset} configuration checks. ${BYellow}Configs${BReset} runs a series of scripts that configure the environment according to lab instructions."
  echo " 1) $(mainmenu_item "${checklist[1]}" "Node Selection")"
  echo " 2) $(mainmenu_item "${checklist[2]}" "Configs")"
  echo " 3) $(mainmenu_item "${checklist[3]}" "Tests")"
  echo " 4) $(mainmenu_item "${checklist[4]}" "Backup Configs")"
  echo " 5) $(mainmenu_item "${checklist[5]}" "Transfer files to UMLs")"
  echo -e "\n q) Quit\n"
  read_opts
  for OPT in ${OPTIONS[@]}; do
    case "$OPT" in
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
        print_title "Configuration Files Backup"
        rsyncfrom cfgfileslist
        checklist[4]=$?
        ;;
      5)
        print_title "Remote Scripts Sync"
        rsyncto testslist conflist
        setval=$?
        testlist[0]=$setval
			  configlist[0]=$setval
        ;;
      "q")
        exit 0
        ;;
      *)
        invalid_option "$OPT"
        ;;
    esac
  done
done

### EOF ###
