#!/bin/bash
source common.sh
tput clear

packages=()
[[ `uname -n` == "server" ]] && packages+=( "bind9" "bind9-doc" "bind9utils" "host" )
[[ `uname -n` == "gw" ]] && packages+=( "quagga" )
#[[ `uname -n` == "client-1" ]] && packages+=( "" )
#[[ `uname -n` == "client-2" ]] && packages+=( "" )
packages+=( "ssh" "ntp" "ntpdate" "nis" "dnsutils" )
for PKG in ${packages[@]}; do
  pkginstall $PKG
done
