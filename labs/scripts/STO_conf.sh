#!/bin/bash
[[ ! `uname -n` == "server" ]] && exit 1
source common.sh
[[ `dpkg -l mdadm` ]] || apt-get install mdadm
[[ `dpkg -l lvm2` ]] || apt-get install lvm2

# Is it properly configured already?
[[ `cat /etc/fstab | grep home1 |sed '/home1/s/\/home.*//'` == "/dev/md1 " ]] && \
[[ `cat /etc/fstab | grep home2 |sed '/home2/s/\/home.*//'` == "/dev/vg1" ]] && \
exit 0

raidmake() {
  techo "Setting up RAID 1 ${Yellow}/dev/md1${Reset}"
  mdadm --create --level=1 --metadata=1.2 --raid-devices=2 /dev/md1 /dev/ubdd /dev/ubde || return 1
  [[ ! -d /home1 ]] && mkdir /home1
  mkfs.ext2 -b 4096 /dev/md1 || return 1
  echo "/dev/md1 /home1 ext2 defaults 0 1" >> /etc/fstab || return 1
  mount /home1 || return 1
  return 0
}

lvmcreate() {
  techo "Setting up LVM ${Yellow}/dev/vg1/home2${Reset}"
  pvcreate /dev/ubd{f,g} || return 1
  vgcreate -s 4K vg1 /dev/md2 || return 1
  lvcreate -l 100%FREE vg1 -n home2 || return 1
  [[ ! -d /home2 ]] && mkdir /home2
  mkfs.ext2 -b 1024 /dev/vg1/home2 || return 1
  echo "/dev/vg1/home2 /home2 ext2 defaults 0 1" >> /etc/fstab || return 1
  mount /home2 || return 1
  return 0
}

local retval=0
raidmake & pid=$! ; progress $pid
[[ $? -eq 0 ]] || retval=1
lvmcreate & pid=$! ; progress $pid
[[ $? -eq 0 ]] || retval=$(( $retval + 2 ))
exit $retval
