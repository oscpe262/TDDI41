#!/bin/bash
shopt -s expand_aliases
alias dig='dig +noall +answer'
b4="b4.sysinst.ida.liu.se"
recreq="recursion requested but not available"
retval=0

[[ ! -z `dig +recurse google.com @server.$b4` ]] && ((retval++))
[[ `dig +recurse google.com @server.$b4 | grep "$recreq"` -eq 0 ]] && ((retval++))
