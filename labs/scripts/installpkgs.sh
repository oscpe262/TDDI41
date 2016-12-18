#!/bin/bash
### Package Install Script #####################################################
# This script installs all needed packages for TDDI41 on the node on which it is
# run. Easily copied and avoids any issues with scripts hanging due to expected
# user input.

tput clear
#echo "deb http://ftp.se.debian.org/debian wheezy main" > /etc/apt/sources.conf
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B48AD6246925553 7638D0442B90D010 6FB2A1C265FFB764

pkginstall() {
  [[ `dpkg-query -W -f='${Status}' $1 2>/dev/null` ]] || apt-get -q -y install $1 --no-install-recommends --force-yes
}

packages=()
if [[ `uname -n` == "server" ]]; then
  packages=( "bind9" "bind9-doc" "bind9utils" "host" "nfs-kerner-server" "sshpass" )
elif [[ `uname -n` == "gw" ]]; then
  packages=( "quagga" )
fi
packages+=( "ssh" )
packages+=( "ntp" )
packages+=( "ntpdate" )
packages+=( "nis" )
packages+=( "dnsutils" )
packages+=( "autofs" )
packages+=( "nfs-client" )
for PKG in ${packages[@]}; do
  pkginstall $PKG
done
