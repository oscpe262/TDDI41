#!/bin/bash
source common.sh
HOST="`uname -n`"
ntlist=( 3 2 2 2 2 2 2 2 2 2 )
TARGETS=( "${c2}" "${c1}" "${srv}" "${gwi}" "${gwe}" "130.236.178.1" "ida-gw.sysinst.ida.liu.se" "www.google.com" )
foo=1

[[ $HOST == "client-2" ]] && ntlist[2]=0
[[ $HOST == "client-1" ]] && ntlist[3]=0
[[ $HOST == "gw" ]] && ntlist[5]=0 && ntlist[6]=0
[[ $HOST == "server" ]] && ntlist[4]=0

ping_test () {
defpingc=2 #default amount of ping tries
  local _target="$1"
  local _count=""
  [[ -z $2 ]] && _count=$defpingc || _count=$2
	techo "Ping ${Yellow}${_target}${Reset}"
	ping -c ${_count} ${_target} &> /dev/null &
  pid=$!; progress $pid
}

check_hostname () {
	techo "Hostname set to (${Yellow}$1${Reset})"
  [[ `uname -n` == $1 ]] &
    pid=$!; progress $pid
}

check_hostname $HOST && ntlist[1]=0 || ntlist[1]=1

for target in ${TARGETS[@]}; do
  ((foo++))
  [[ ${ntlist[$foo]} -eq 0 ]] && continue
  ping_test "${target}"
  ntlist[$foo]=$?
done
echo ""
inArray "1" "${ntlist[@]}" && exit 1 || exit 0
