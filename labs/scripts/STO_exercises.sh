#!/bin/bash
[[ ! `uname -n` == "server" ]] && exit 1
[[ `dpkg-query -W -f='${Status}' mdadm 2>/dev/null` ]] || apt-get install mdadm
[[ `dpkg-query -W -f='${Status}' lvm2 2>/dev/null` ]] || apt-get install lvm2

################################################################################
### Part 1: RAID ###############################################################
################################################################################
# Linux (like most operating systems) supports software RAID. In Linux, you
# control software RAID using the mdadm command.

#Using mdadm, you create new block devices (named e.g. /dev/md0, /dev/md1),
# which represent various configurations of other block devices. Since software
# RAID doesn't really care what the underlying block devices are, you can create
# RAID sets consisting of other RAID sets, of disks, or even data on other hosts
# (by using network block devices).

# Your server has been configured with four extra block devices, /dev/ubdd,
# dev/ubde, /dev/ubdf, and /dev/ubdg, each 5MB in size, which will be used for
# experiments with RAID.

### Exercise 4: Configure RAID 0 ###############################################
# 4-1 Combine /dev/ubde and /dev/ubdf into a RAID 0 set named /dev/md0
mdadm --create --verbose --level=0 --metadata=1.2 --raid-devices=2 /dev/md0 /dev/ubde /dev/ubdf

# 4-2 Create a file system on /dev/md0 and mount it on /mnt. How much space is
# there in the file system?
mkfs.ext3 /dev/md0
mount /dev/md0 /mnt
df /dev/md0

# A: 8.8 MB
# Report: No report required.

# Before proceeding with the next exercise, you will have to unmount /dev/md0
# and stop it with mdadm in order to make the devices available again.
umount /dev/md0
mdadm -S /dev/md0
mdadm --zero-superblock /dev/ubd{e,f}

### Exercise 5: Configure RAID 1 ###############################################
# 5-1 Combine /dev/ubde and /dev/ubdf into a RAID 1 set named /dev/md0.
mdadm --create --verbose --level=1 --metadata=1.2 --raid-devices=2 /dev/md0 /dev/ubde /dev/ubdf

# 5-2 Create a file system on /dev/md0 and mount it on /mnt. How much space is
# there in the file system? Why?
mkfs.ext3 /dev/md0
mount /dev/md0 /mnt
df /dev/md0

# A: 4.8 MB

# 5-3 Add /dev/ubdg as a spare in /dev/md0, then fail /dev/ubdf (using mdadm).
# What happens?
mdadm --add /dev/md0 /dev/ubdg
cat /proc/mdstat
mdadm /dev/md0 -f /dev/ubdf
cat /proc/mdstat

# A: The array keeps running on one disk (/dev/udbe)

# Before proceeding with the next exercise, you will have to unmount /dev/md0
# and stop it with mdadm in order to make the devices available again.
umount /dev/md0
mdadm -S /dev/md0
mdadm --zero-superblock /dev/ubd{e,f,g}

### Exercise 6: Configure RAID 1+0 #############################################
# 6-1 Combine /dev/ubdd, /dev/ubde, /dev/ubdf, and /dev/ubdg into a RAID 1+0 de-
# vice named /dev/md0. You may need to create intermediate raid sets to do this.
mdadm --create --verbose --level=1 --metadata=1.2 --raid-devices=2 /dev/md11 /dev/ubdd /dev/ubde
mdadm --create --verbose --level=1 --metadata=1.2 --raid-devices=2 /dev/md12 /dev/ubdf /dev/ubdg
mdadm --create --verbose --level=0 --metadata=1.2 --raid-devices=2 /dev/md0 /dev/md11 /dev/md12

#6-2 Create an ext2 file system on /dev/md0 and mount it on mnt. How much space
# is there in the file system?
mkfs.ext3 /dev/md0
mount /dev/md0 /mnt
df /dev/md0

# A: 8.8

# Before proceeding with the next part, you will have to unmount /dev/md0 and stop it with mdadm in order to make the devices available again.
umount /dev/md0
mdadm -S /dev/md{0,11,12}
mdadm --zero-superblock /dev/ubd{d,e,f,g}

################################################################################
### Part 2: LVM2 ###############################################################
################################################################################
# LVM is a volume manager for Linux that allows you to work logical, rather than physical, volumes. Logical volumes allow a degree of flexibility that physical volumes simply cannot offer. Each operating system has its own way of handling logical volumes, but most work more or less like LVM. In the future, however, we can expect to see logical volume management, RAID, and the file system itself merged, as Sun has done with ZFS in Solaris.

### Exercise 7: Create logical volumes #########################################
# 7-1 Create physical volumes on /dev/ubdd, /dev/ubde, and /dev/ubdf.
pvcreate /dev/ubd{d,e,f}

# 7-2 Create a single volume group named vg1 containing all physical volumes. Since you will be working with very small volumes, make sure you set the physical extent size appropriately.
vgcreate -s 1k vg1 /dev/ubdd /dev/ubde /dev/ubdf

# 7-3 Create two logical volumes (lvol0 and lvol1), each 2MB in size. This will create devices named /dev/vg1/lvol0 and /dev/vg1/lvol1, which can be used just like any other block device.
lvcreate -L 2M -n lvol0 vg1
lvcreate -L 2M -n lvol1 vg1

# 7-4 Create ext2 file systems, i.e. file systems without journals (without the -j option) on both logical volumes, and mount them as /lv0 and /lv1. If you create filesystems with journals, then there will be hardly any room for files, and the remaining labs won't work.
mkfs.ext2 /dev/vg1/lvol0
mkfs.ext2 /dev/vg1/lvol1
mkdir /lv{0,1}
mount /dev/vg1/lvol0 /lv0
mount /dev/vg1/lvol1 /lv1

# Report: No report required.


### Exercise 8: Manipulate volumes #############################################
# One of the advantages of using logical, rather than physical, volumes, is that they can be resized. Additionally, if the volume group does not have sufficient free space, additional physical volumes can be added.

# 8-1 Attempt to create a 2.5MB file on /lv1. This should fail.
[[ `dd if=/dev/zero of=/lv1/foo bs=2.5M count=1` ]] && echo "8-1 Failed as expected."

# 8-2 Resize lvol0 to 3MB in size. Don't forget to resize the ext3 file system that it contains as well (using resize2fs). Mount it and attempt to create a 2.5MB file again. This time it should work.
rm /lv1/foo
lvresize -L +1M -r /dev/vg1/lvol0
dd if=/dev/zero of=/lv0/foo bs

# 8-3 Add a new physical volume to vg1. You can use /dev/ubdg for this.
pvcreate /dev/ubdg
vgextend vg1 /dev/ubdgmdadm --create --verbose --level=1 --metadata=1.2 --raid-devices=2 /dev/md11 /dev/ubdd /dev/ubde


# 8-4 Migrate any data off the physical volume /dev/ubdd to other volumes in vg1 and remove /dev/ubdd from vg1. You can now use /dev ubdd for something else.
pvmove /dev/ubdd /dev/ubdg
vgreduce vg1 /dev/ubdd

#Report: No report required.

### Exercise 9: Snapshots ######################################################
# Most logical volume managers support snapshots, which are copies of a logical volume as it appeared when the snapshot was created. Snapshots are created by marking the volume as copy-on-write, which makes it possible to create snapshots instantaneously. Snapshots have many applications, but the most common is probably to make backups of a file system without having to take it off-line. First a snapshot is created, and then a backup is made of the snapshot.

# [!] When a snapshot is made, only blocks that have been written to disk are actually included in the snapshot. Since the operating system typically delays writing data to disk (for performance reasons), a careless snapshot can miss data. The procedure in the exercise below is not recommended for production systems.

# 9-1 Copy some files to the /lv1 directory (it doesn't matter which files).
cp /etc/default/* /lv1

# 9-2 Use the sync command to write any buffered data to disk, and then create a snapshot of vg1/lvol1.
sync
lvcreate --size 1M --snapshot --name snap01 /dev/vg1/lvol1

# 9-3 Run fsck to check the consistency of the new snapshot (because you copied a live file system, it is likely that fsck will have to fix something), then mount it as /sn
fsck.ext2 /dev/vg1/snap01
mkdir /sn
mount /dev/vg1/snap01 /sn

# 9-4 Edit the files in /lv1 and then compare them to the corresponding files in /sn.
echo "foo" >> /lv1/ntp
diff /lv1/ntp /sn/ntp

# 9-5 Unmount /sn and remove the snapshot from the volume group.
umount /sn
lvremove /dev/vg1/snap01

#Report: No report required.

################################################################################
### Part 3: Putting it into practice
################################################################################
# In this part of the lab you will use RAID and LVM to create directories that are needed in later labs (in particular in the NFS lab). Before proceeding with this exercise, you need to remove all logical volumes, volume groups, and physical volumes, created in the previous part, and any RAID devices created in the first part of this lab.
umount /lv{0,1}
lvremove /dev/vg1/*
vgremove /dev/vg1
pvremove /dev/ubd{d,e,f,g}

### Exercise 10: Create home directory volumes #################################
# 10-1 Use RAID 1 to create a device on which you place an ext2 file system optimized for many small files, that you mount as /home1 on the server. Make sure that /home1 is correctly mounted at boot.
mdadm --create --verbose --level=1 --metadata=1.2 --raid-devices=2 /dev/md1 /dev/ubdd /dev/ubde
mkdir /home1
mkfs.ext2 -b 1024 /dev/md1
echo "/dev/md1 /home1 ext2 defaults 0 1" >> /etc/fstab
mount /home1

# 10-2 Use LVM to create a device on which you place an ext2 file system optimized for a smaller number of large files, that you mount as /home2 on the server. Make sure that /home2 is correctly mounted at boot.
pvcreate /dev/ubd{f,g}
vgcreate -s 4K vg1 /dev/ubdf /dev/ubdg
lvcreate -l 100%FREE vg1 -n home2
mkdir /home2
mkfs.ext2 -b 4096 /dev/vg1/home2
echo "/dev/vg1/home2 /home2 ext2 defaults 0 1" >> /etc/fstab
mount /home2

# Report: No report required.

################################################################################
### Part 4: Q&A ################################################################
################################################################################
# This lab doesn't require any reports, so let's ask some theoretical questions instead.

# See ../tex/STO.pdf
