#!/bin/bash
gr="\e[1;32m"
rd="\e[1;31m"
def="\e[0m"

# GW test
if [ `uname -n` == "gw" ]
then
  printf "$gr%s$def\n" "hostname ok"
else
  printf "$rd%s$def\n" "hostname nok"
fi
