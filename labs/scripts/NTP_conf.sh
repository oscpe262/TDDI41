#!/bin/bash
#[[ ! -f common.sh ]] && echo -e "Missing dependency: common.sh" && exit 1
#source common.sh

packages=( "ntp" "ntpdate" )
backupdir="/etc/.bak/"
conf="/etc/ntp.conf"
bca="130.236.178.159"
firstrun=0

################################################################################
# The NTP server should be installed on your router. Placing the NTP server on
# your router is reasonable as many NTP servers today include NTP servers.
################################################################################
for PKG in ${packages[@]}; do
  [[ ! `dpkg -l ${PKG}` ]] && apt-get install ${PKG}
done
[[ -d ${backupdir} ]] || mkdir ${backupdir}
[[ ! -f ${backupdir}ntp.conf ]] && cp ${conf} ${backupdir} # Backup is nice to have
cp ${backupdir}ntp.conf ${conf} # Start with default conf

################################################################################
# 3-1 Install the necessary software and configure your router as an NTP server.
# It should use ida-gw.sysinst.ida.liu.se as its reference clock.
# It should allow no other peers to update its clock.
# Anyone should be allowed to read the clock.
################################################################################
if [[ `uname -n` == "gw" ]]; then
  sed -i '/statsdir/s/^#//' ${conf} # Enable logging
  sed -i 's/\ noquery/\ #noquery/g' ${conf} # Allow queries
  sed -i '/server/d' ${conf}
  echo "server ida-gw.sysinst.ida.liu.se" >> ${conf} # set reference clock
  sed -i "s/#broadcast.*/broadcast ${bca}/g" ${conf} # broadcast to sub nw.
fi

################################################################################
# 3-2 Configure your clients and your server as NTP clients of your router.
# They should either get the time directly from the router or accept broadcast
# or multicast time announcements from the router.
################################################################################
if [[ ! `uname -n` == "gw" ]]; then
  sed -i '/server/d' ${conf}
  echo "server gw.b4.sysinst.ida.liu.se" >> ${conf} # set reference clock
  sed -i '/broadcastclient/s/^#//' ${conf} # listen to broadcast
fi

/etc/init.d/ntp restart

################################################################################
# 3-3 Explain the output of ntpq -p.
################################################################################
### See NTP.pdf

################################################################################
# 3-4 Verify that NTP works.
################################################################################
### See NTP_test.sh, or something ...
