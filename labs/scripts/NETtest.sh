#!/bin/bash
[[ ! -f common.sh ]] && echo -e "Missing dependency: common.sh" && exit 1
source common.sh

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
