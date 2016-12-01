#!/bin/bash

### NET Configuration Script ###################################################
# This script will set up the node it is run on according to the NET lab. Copy
# the script to each UML (this might have to be done by copy and paste),
# chmod +x it, and run. It is currently configured to fit group b4 and cannot be
# changed during runtime. Make adjustments accordingly if necessary.
# The script is made by oscpe262 and matla782.

### VARS #######################################################################
nw=130.236.178
gwe=$nw.17
gwi=$nw.153
srv=$nw.154
c1=$nw.155
c2=$nw.156
sila="sysinst.ida.liu.se"
b4="b4.$sila"
BASEPATH="/etc"

### HELP FUNCTIONS #############################################################
ifaces() {
  local TARGET="$BASEPATH/network/interfaces"
  sed -i "/^auto/s/$/ $1/" $TARGET
  echo -e "\niface $1 inet $2" >> $TARGET
  [[ ! $1 == "lo" ]] && echo -e "\taddress $3\n\tnetmask 255.255.255.$4\n\tnetwork $5\n\tgateway $6" >> $TARGET
}

hosts() {
  echo "${1}" >> $BASEPATH/hosts
}

edit_resolv() {
  local TARGET="$BASEPATH/resolv.conf"
  echo "domain ida.liu.se" > $TARGET
  echo "search ida.liu.se" >> $TARGET
  echo "nameserver ${nw}.9" >> $TARGET
  echo "nameserver ${nw}.154" >> $TARGET
}

install_pkg() {
  [[ `dpkg -s $1` ]] || apt-get -q -y install $1 --no-install-recommends
}

restart_services() {
  ip route add default via 130.236.178.1
  $BASEPATH/init.d/networking restart
}

### MAIN SCRIPT ################################################################
read -p "Enter hostname (i.e. gw, server, client-1, or client-2): " HOST
echo "$HOST" > $BASEPATH/hostname
echo "auto" > $BASEPATH/resolv.conf
echo "deb http://ftp.se.debian.org/debian wheezy main" > /etc/apt/sources.conf
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B48AD6246925553 7638D0442B90D010 6FB2A1C265FFB764

edit_resolv
sed -i "s/^hosts.*$/hosts:\t\tfiles dns/g" $BASEPATH/nsswitch.conf
ifaces "lo" "loopback"

sed -i "/$sila/d" $BASEPATH/hosts

if [[ $HOST == "gw" ]]; then
  hosts "$gwe b4-gw.$sila b4-gw"
  hosts "$gwi $HOST.$b4 $HOST"
  ifaces "eth0" "static" "$gwi" "248" "${nw}.152" "130.236.178.17"
  ifaces "eth1" "static" "$gwe" "192" "${nw}.0" "130.236.178.1"
  sed -i "/net.ipv4.ip_forward/ s/.*/net.ipv4.ip_forward=1/" $BASEPATH/sysctl.conf
  restart_services
  install_pkg "quagga"
else
  [[ $HOST == "server" ]] && addr=$srv
  [[ $HOST == "client-1" ]] && addr=$c1
  [[ $HOST == "client-2" ]] && addr=$c2
  hosts "$addr $HOST.$b4 $HOST"
  ifaces "eth0" "static" "$addr" "248" "$nw.152" "$nw.153"
  restart_services
fi

install_pkg "ssh"
