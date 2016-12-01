#!/bin/bash
[[ ! `uname -n` == "server" ]] && exit 1
source common.sh
packages=( "mdadm" "lvm2" )
for PKG in ${packages[@]}; do
  pkginstall $PKG
done

raidmake() {
  techo "Setting up RAID 1 ${Yellow}/dev/md1${Reset}"
  mdadm --create --level=1 --metadata=1.2 --raid-devices=2 /dev/md1 /dev/ubdd /dev/ubde || return 1
  [[ ! -d /home1 ]] && mkdir /home1
  mkfs.ext2 -b 1024 /dev/md1 || return 1
  echo "/dev/md1 /home1 ext2 defaults 0 1" >> /etc/fstab || return 1
  mount /home1 || return 1
  return 0
}

lvmcreate() {
  techo "Setting up LVM ${Yellow}/dev/vg1/home2${Reset}"
  pvcreate /dev/ubd{f,g} || return 1
  vgcreate -s 4K vg1 /dev/ubdf /dev/ubdg || return 1
  lvcreate -l 100%FREE vg1 -n home2 || return 1
  [[ ! -d /home2 ]] && mkdir /home2
  mkfs.ext2 -b 4096 /dev/vg1/home2 || return 1
  echo "/dev/vg1/home2 /home2 ext2 defaults 0 1" >> /etc/fstab || return 1
  mount /home2 || return 1
  return 0
}

storageundo() {
  techo "Removing Configs, STO"
  umount -f /home1
  umount -f /home2
  lvremove -f /dev/vg1/home2
  vgremove -f /dev/vg1
  pvremove -f /dev/ubd{f,g}
  mdadm -S /dev/md1
  mdadm --zero-superblock /dev/ubd{d,e}
  sed -i '/home/d' /etc/fstab
}

if [[ $1 == "erase" ]]; then
# Is it properly configured already?
  [[ `cat /etc/fstab | grep home1 |sed '/home1/s/\/home.*//'` == "/dev/md1 " ]] && \
  [[ `cat /etc/fstab | grep home2 |sed '/home2/s/\/home.*//'` == "/dev/vg1" ]] || \
  exit 1
  storageundo & pid=$! ; progress $pid
  exit $?
fi

retval=0
# Is it properly configured already?
[[ `cat /etc/fstab | grep home1 |sed '/home1/s/\/home.*//'` == "/dev/md1 " ]] && \
[[ `cat /etc/fstab | grep home2 |sed '/home2/s/\/home.*//'` == "/dev/vg1" ]] && \
exit 0

raidmake & pid=$! ; progress $pid
[[ $? -eq 0 ]] || retval=1
lvmcreate & pid=$! ; progress $pid
[[ $? -eq 0 ]] || retval=$(( $retval + 2 ))
exit $retval
