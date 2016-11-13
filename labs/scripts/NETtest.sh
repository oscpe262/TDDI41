#!/bin/bash
[[ ! -f NET_funcs.sh ]] && echo -e "Missing dependency: NET_funcs.sh" && exit 1
source NET_funcs.sh

# Once properly implemented, output should be modified.
#[[ -z $1 ]] && echo -e "run with ./`basename $0` <hostname>" && exit 1
#HOST=$1 && shift

HOST=Saiph
### NET TEST MAIN FUNCTION #####################################################

test_net() {
  check_hostname $HOST
  [[ ! $HOST == "client-2" ]] && ping_test "${c2}" "Client-2 Internal, IP"
  [[ ! $HOST == "client-1" ]] && ping_test "${c1}" "Client-1 Internal, IP"
  [[ ! $HOST == "server" ]] && ping_test "${srv}" "Server Internal, IP"
  [[ ! $HOST == "gw" ]] && ping_test "${gwi}" "Gateway Internal, IP"
  [[ ! $HOST == "gw" ]] && ping_test "${gwe}" "Gateway External, IP"
  ping_test "${nw}.1" "ida-gw, IP"
  ping_test "ida-gw.sysinst.ida.liu.se" "ida-gw"
  ping_test "www.google.com" "World-Wide Connectivity"
}

### EOF ###
