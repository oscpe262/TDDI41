#!/bin/bash
source common.sh

[[ ! `uname -n` == "server" ]] && exit 2

DEVICES=( "md1" "vg1" "home2" )

testdevice() {
  techo "Trying to find ${Yellow}/dev/$1${Reset}"
  STRING=`find /dev -name $1`
  [[ -z $STRING ]] && return 1 || return 0
}

echo ""
for DEV in ${DEVICES[@]}; do
  testdevice "${DEV}" &
  pid=$! ; progress $pid
  [[ ! $? == 0 ]] && echo "" && exit 1
done
echo -e "\n\n"
exit 0
