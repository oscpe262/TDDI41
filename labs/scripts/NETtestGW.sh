#!/bin/bash
gr="\e[1;32m"
rd="\e[1;31m"
def="\e[0m"
greentext="$gr%s$def\n"
redtext="$rd%s$def\n"

# gw test
if [ `uname -n` == "gw" ]
then
  printf "${greentext}" "hostname ok"
else
  printf "${redtext}" "hostname nok"
  #exit 1
fi

ping -c 1 130.236.178.153 &> /dev/null
if [ $? -eq 0 ]; then
  printf "${greentext}" "Ping 130.236.178.153 successful!"
else
  printf "${redtext}" "Could not connect to gw (local, IP)."
  exit 1
fi

ping -c 1 130.236.178.17 &> /dev/null
if [ $? -eq 0 ]; then
  printf "${greentext}" "Ping 130.236.178.17 successful!"
else
  printf "${redtext}" "Could not connect to gw (ext, IP)."
  exit 1
fi

ping -c 1 130.236.178.1 &> /dev/null
if [ $? -eq 0 ]; then
  printf "${greentext}" "Ping 130.236.178.1 successful!"
else
  printf "${redtext}" "Could not connect to ida-gw (IP)."
  exit 1
fi


ping -c 1 ida-gw.sysinst.ida.liu.se &> /dev/null
if [ $? -eq 0 ]; then
  printf "${greentext}" "Ping ida-gw.sysinst.ida.liu.se successful!"
else
  printf "${redtext}" "Could not connect to ida-gw (name resolved)."
  exit 1
fi

ping -c 1 www.google.com &> /dev/null
if [ $? -eq 0 ]; then
  printf "${greentext}" "Ping www.google.com successful!"
  printf "${greentext}" "We have world-wide connectivity"
else
  printf "${redtext}" "No world-wide connectivity"
  exit 1
fi

exit 0

#traceroute 8.8.8.8 --max-hops=2 -q 1 > tmp
#if [ $? -eq 0 ]; then
#  awk '{print $3}' tmp | sed 's/(//g; s/)//g; s/8.8.8.8//g; /^$/d' | tail -n 1 > tmp2
  # bekräfta att ej finns i egentilldelade route tables
#  rm tmp
#  rm tmp2
#  printf "${greentext}" "foo"
#else
#  printf "${redtext}" "Manually added routes found which should not be here ..."
#  exit 1
#fi
