#!/bin/bash
source common.sh
SRCS=("CL1" "CL2" "SRV" "GW")
FILES=("hosts" "hostname" "network/interfaces" "sysctl.conf" "resolv.conf" "nsswitch.conf" "quagga")
for SRC in ${SRCS[@]}; do
  [[ $SRC == "CL1" ]] && srca=${c1}
  [[ $SRC == "CL2" ]] && srca=${c2}
  [[ $SRC == "SRV" ]] && srca=${srv}
  [[ $SRC == "GW" ]] && srca=${gwe}
    for FILE in ${FILES[@]}; do
      techo "$SRC /etc/${FILE}"
      [[ ! $SRC == "GW" ]] && [[ $FILE == "quagga" ]] && cecho "\b${Blue}Skipping...${Reset}" && continue
      rsync -aruz -e "ssh" root@${srca}:/etc/${FILE} `pwd`/../configs/$SRC/etc/ &> /dev/null &
      pid=$!; progress $pid
    done
  done
rm $LOG
