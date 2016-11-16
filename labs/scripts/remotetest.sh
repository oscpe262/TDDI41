#!/bin/bash
### CALL: remotetest.sh ["hostname"] "TEST"
[[ -f "common.sh" ]] && source common.sh || exit 1

[[ $2 == "NET" ]] && deps=( "NETtest.sh" "NET_funcs.sh" )
[[ $2 == "DNS" ]] && deps=( "DNS_srvconf.sh" )
[[ $2 == "SCT" ]] && deps=( "SCT7.sh" "SCT7_funcs.sh" "DNS_srvconf.sh" )

for DEP in ${deps[@]}; do
  [[ ! -f  ${DEP} ]] && echo "Could not find source: ${DEP}" && pause && exit 1
  source $DEP
done

if [[ $2 == "NET" ]] && [[ " ${nodenames[@]} " =~ " ${1} " ]]; then
 	test_net $1
	exit $?
fi
