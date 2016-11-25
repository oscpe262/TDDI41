#!/bin/bash
source common.sh
shopt -s expand_aliases
alias dig='dig +noall +answer'

b4="b4.sysinst.ida.liu.se"
arpa="152-159.178.236.130.in-addr.arpa"
recreq="recursion requested but not available"

retval=0
### test name resolution
[[ -z `dig client-1.${b4}` ]] && ((retval++))
echo "$retval"
# 5-1 a1 answer
[[ -z `dig client-1.${b4} @server.$b4` ]] && ((retval++))
echo "$retval"
[[ -z `dig ptr 154.$arpa` ]] && ((retval++))
echo "$retval"
[[ -z `dig ptr -x 130.236.178.155` ]] && ((retval++))
echo "$retval"
[[ -z 'dig ns $arpa' ]] && ((retval++))
echo "$retval"
# 5-1, a2 non recursive
[[ -z `dig +all client-1.${b4} @server.$b4 | grep "${recreq}"` ]] && ((retval++))
echo "$retval"
# 5-1 c,d
[[ ! -z `dig google.com @server.$b4` ]] && ((retval++))
echo "$retval"
exit $retval


# auth test, non-rec from outside
# rec from inside @server.b4
#cachning - query1 >> timestamp1, q2 >> t2, diff t2,t1 < 10-20(ish) ms
