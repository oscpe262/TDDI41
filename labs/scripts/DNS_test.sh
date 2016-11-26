#!/bin/bash
source common.sh
shopt -s expand_aliases
alias dig='dig +noall +answer'

[[ -f DNS_srvconf.sh ]] && rm DNS_srvconf.sh

b4="b4.sysinst.ida.liu.se"
arpa="152-159.178.236.130.in-addr.arpa"
recreq="recursion requested but not available"

### annotera!!!

retval=0
ntecho "External tests:"
### test name resolution
techo "Name resolving${Yellow}${Reset}"
[[ ! -z `dig client-1.${b4}` ]] &
pid=$! ; progress $pid
retval=$(($retval+$?))

techo "PTR records exist${Yellow}${Reset}"
[[ ! -z `dig ptr 154.$arpa` ]] &
pid=$! ; progress $pid
retval=$(($retval+$?))

techo "${Yellow}${Reset}Reverse lookup works"
[[ ! -z `dig ptr -x 130.236.178.155` ]] &
pid=$! ; progress $pid
retval=$(($retval+$?))

techo "NS for ${Yellow}${arpa}${Reset}"
[[ ! -z 'dig ns $arpa' ]] &
pid=$! ; progress $pid
retval=$(($retval+$?))

# 5-1 a1 answer
techo "(${Yellow}5-1 a${Reset}) NS answers queries about int. nw."
[[ ! -z `dig client-1.${b4} @server.$b4` ]] &
pid=$! ; progress $pid
retval=$(($retval+$?))

# 5-1, a2 non recursive
techo "(${Yellow}5-1 a${Reset}) Auth. answer, non-recursive"
[[ ! -z `dig +all +aaonly +norecurse client-1.${b4} @server.$b4` ]]&
pid=$! ; progress $pid
retval=$(($retval+$?))
# 5-1 c,d

techo "(${Yellow}5-1 c${Reset}) No ext. recursive q:s about int. nw."
[[ ! -z `dig +all client-1.${b4} @server.$b4 | grep "${recreq}"` ]] &
pid=$! ; progress $pid
retval=$(($retval+$?))

techo "(${Yellow}5-1 d${Reset}) No ext. queries about ext. nw."
[[ -z `dig google.com @server.$b4` ]] &
pid=$! ; progress $pid
retval=$(($retval+$?))

[[ $retval -ne 0 ]] && sleep 3
exit $retval


# auth test, non-rec from outside
# rec from inside @server.b4
#cachning - query1 >> timestamp1, q2 >> t2, diff t2,t1 < 10-20(ish) ms
