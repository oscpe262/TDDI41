#/bin/bash
#[[ ! -f common.sh ]] && echo -e "Missing dependency: common.sh" && exit 1
#source common.sh

defpingc=3 #default amount of ping tries

ping_test () {
#ping target_ip test_description [ping count]
  local _target="$1"
  local _test="$2"
  local _count=""
  [[ -z $3 ]] && _count=$defpingc || _count=$3
  techo "Ping ${Yellow}${_target}${Reset} (${_test})"
  if [[ $VERBOSE -eq 1 ]]; then
    ping -c ${_count} ${_target}
  else
     ping -c ${_count} ${_target} &> /dev/null &
     pid=$!; progress $pid
  fi
}

check_hostname () {
  techo "${Yellow}Hostname${Reset} set properly"
  [[ `uname -n` == "${1}" ]] &
  pid=$!; progress $pid
}
