#!/bin/bash
[[ ! -f common.sh ]] && echo -e "Missing dependency: common.sh" && exit 1
source common.sh

[[ -z $1 ]] && echo -e "run with ./`basename $0` <hostname>" && exit 1
HOST=$1 && shift

while [ $# -ne 0 ]
do
  arg="$1"
  case "$arg" in
    # Failed tests will force the script to exit.
    -f)
      FORCE_EXIT=1
      ;;
    -v)
      VERBOSE=1
      ;;
    -fv)
      FORCE_EXIT=1
      VERBOSE=1
      ;;
    -vf)
      FORCE_EXIT=1
      VERBOSE=1
      ;;
    *)
      echo -e "unknown argument '${arg}'"
      ;;
  esac
  shift
done

tput clear
check_hostname $HOST
[[ ! $HOST == "client-2" ]] && ping_test "${c2}" "Client-2 Internal, IP"
[[ ! $HOST == "client-1" ]] && ping_test "${c1}" "Client-1 Internal, IP"
[[ ! $HOST == "server" ]] && ping_test "${srv}" "Server Internal, IP"
[[ ! $HOST == "gw" ]] && ping_test "${gwi}" "Gateway Internal, IP"
[[ ! $HOST == "gw" ]] && ping_test "${gwe}" "Gateway External, IP"
ping_test "${nw}.1" "ida-gw, IP"
ping_test "ida-gw.sysinst.ida.liu.se" "ida-gw"
ping_test "www.google.com" "World-Wide Connectivity"
exit 0
