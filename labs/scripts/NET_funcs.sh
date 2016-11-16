#/bin/bash
#[[ ! -f common.sh ]] && echo -e "Missing dependency: common.sh" && exit 1
#source common.sh

defpingc=3 #default amount of ping tries

ping_test () {
#ping target_ip [ping count]
  local _target="$1"
  local _count=""
  [[ -z $2 ]] && _count=$defpingc || _count=$2
  if [[ $VERBOSE -eq 1 ]]; then
    ping -c ${_count} ${_target}
  else
		techo "Ping ${Yellow}${_target}${Reset}"
		ping -c ${_count} ${_target} &> /dev/null &
    pid=$!; progress $pid
  fi
}

check_hostname () {
	techo "Hostname set to (${Yellow}$1${Reset})"
  [[ `uname -n` == $1 ]] &
    pid=$!; progress $pid
}

### EOF ###
