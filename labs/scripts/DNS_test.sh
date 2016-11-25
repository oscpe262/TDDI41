#!/bin/bash
source common.sh
shopt -s expand_aliases
alias dig='dig +noall +answer'

b4="b4.sysinst.ida.liu.se"
arpa="152-159.178.236.130.in-addr.arpa"

retval=0
### test name resolution
[[ -z `dig client-1.${b4}` ]] && ((retval++))
[[ -z `dig client-1.${b4} @server.$b4` ]] && ((retval++))
[[ -z `dig ptr 154.$arpa` ]] && ((retval++))
[[ -z `dig ptr -x 130.236.178.155` ]] && ((retval++))
[[ -z 'dig ns $arpa' ]] && ((retval++))
exit $retval
