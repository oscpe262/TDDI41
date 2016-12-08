#!/bin/bash
source common.sh
shopt -s expand_aliases
alias dig='dig +noall +answer'
b4="${GROUP}.sysinst.ida.liu.se"
recreq="recursion requested but not available"
retval=0

# Working at all?
[[ -z `dig +recurse google.com @server.$b4` ]] && ((retval++))

# Recursion working as intended from the internal nw?
[[ ! `dig +recurse google.com @server.$b4 | grep "$recreq"` -eq 0 ]] && ((retval++))

# Check Cache TTL counting down,
ttl1="`dig +noall +answer google.com @server.$b4 | sed 's/IN.*// ; s/google.com.// ;  s/\t//g'`"
sleep 1.5
ttl2="`dig +noall +answer google.com @server.$b4 | sed 's/IN.*// ; s/google.com.// ;  s/\t//g'`"
[[ -z $ttl1 ]] && ((retval++))
[[ $ttl1 == $ttl2 ]] && ((retval++))

exit $retval
