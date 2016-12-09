#!/bin/bash
source common.sh
# ref: https://wiki.debian.org/NFSServerSetuphttps://wiki.debian.org/NFSServerSetup

amaster="/etc/auto.master"
alocal="/etc/auto.local"
ahome="/etc/auto.home"

/etc/init.d/autofs stop

### NFS Main Lab ###############################################################
# [!] One of the most important reasons for having a server is to store files on it. By using a central file server, all users in a network can access all files, and services like backup and recovery are far easier to implement on a server than on a diverse set of workstations.

# Although it is not required, you should have installed and configured a directory service, such as NIS, before starting this exercise. Otherwise you will have to re-do parts of it.

# Time taken 2005: 1-9 hours, average 5 hours (no reliable information for 2006) Past problems: NFS itself seems to cause very few problems. The automounter causes more problems. The documentation for the automounter has a lot to do with that, but most of the difficult problems have been caused by not understanding how the automounter works and what its purpose is.

### Part 1: Network File System ################################################
# There are several network file systems that can be used to implement a file server. Microsoft systems almost always use the SMB protocol (a.k.a. CIFS, the Common Internet File System). In the Unix world there is greater diversity. NFS, Network File System, is one of the most common systems. While it isn't a marvel of engineering, NFS has been around for a long time and gets the job done. Some users prefer AFS, the Andrew File System, which is technically superior to NFS, but also more complicated. Beyond those there are a multitude of other options.

# For this lab you may choose any network file system you want. If you are unsure or lack previous experience with network file systems, use NFS.

# Linux supports two different NFS servers: the user space server and the kernel space server. Use the kernel space server for this lab.

# 5-1 Install an automounter on the clients and on the server. The autofs package is recommended, but you may try amd or some other automounter if you prefer. Note the warning above.
[[ `dpkg -s autofs` ]] || pkginstall "autofs"
[[ ! -f /etc/.bak/auto.master ]] && cp ${amaster} /etc/.bak/auto.master
  cp /etc/.bak/auto.master /etc


  ### Exercise 3: Configure a file server ########################################
# 3-1 Set your server up as a file server using NFS (or the network file system of your choice).
if [[ `uname -u` ==  "server" ]]; then
  techo "Set server as file server (NFS)"
  pkginstall "nfs-kernel-server"
  #[[ -f /etc/default/portmap ]] && sed -i 's/^OPTIONS/#OPTIONS/' /etc/default/portmap
  sed -i '/^portmap/d' /etc/hosts.allow
  echo "portmap: ${nw}.$STARTADDRESS/255.255.255.248\n\t127.0.0.1" >> /etc/hosts.allow
  echo "portmap: 0.0.0.0" >> /etc/hosts.deny
# 3-2 Configure your server to export the /usr/local directory to all clients. It must not be possible to access /usr/local from any other system. Your server must not treat root users on the client as root on the exported file system.

  echo -e "/home\t auto.home" > ${amaster}
  echo -e "/usr/local\t auto.local" >> ${amaster}

  echo -e "*\t server.${DDNAME}:/usr/local/&" > ${alocal} ###

  echo -e "*\t server.${DDNAME}:/home1/&" > ${ahome}
  echo -e "*\t server.${DDNAME}:/home2/&" >> ${ahome}

  [[ ! -f /etc/.bak/exports ]] && cp /etc/exports /etc/.bak/exports
  cp /etc/.bak/exports /etc
  mntopts="(fsid=0,rw,sync,no_root_squash,no_subtree_check)"
  echo "/usr/local ${nw}.${STARTADDRESS}/29(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
# 4-3 Configure your NFS server to export /home1 and /home2 with the appropriate permissions to your clients (and only your clients).
# For more clients, we would of course mask out ...
  echo "/home1 ${c1}${mntopts} ${c2}${mntopts}" >> /etc/exports
  echo "/home2 ${c1}${mntopts} ${c2}${mntopts}" >> /etc/exports
  exportfs -rav

  /etc/init.d/nfs-kernel-server restart
fi
# 3-3 Configure your clients to automatically mount /usr/local from the server at boot.
# 5-2 Configure the automounter so it mounts /home/USERNAME from the user's real home directory (on the NFS server). Make /home an indirect mount point - that is, the automounter will automatically mount subdirectories of /home, but not /home itself. You will probably need one line per user in the configuration file.
techo "3-3 Configure your clients to automatically mount /usr/local from the server at boot."
pkginstall "nfs-common"
sed -i '/automount/d' /etc/nsswitch.conf
echo -e "automount:\tfiles nis" >> /etc/nsswitch.conf
sed -i '/auto\.master/d' ${amaster}
echo -e "+auto.master" >> ${amaster}

[[ `uname -n == "server"` ]] && /usr/lib/yp/ypinit -m
/etc/init.d/nis restart

### Report: Automated test cases that demonstrate that your NFS service is working properly.
## See NFS_test.sh

#[!] Due to a quirk in some versions of Linux, you may need to set the fsid option when exporting directories from the server, or the client will ignore all but the first set of mount options (e.g. read-only, read-write) used to mount those directories. For example, imagine that the server has a file system named /nfs and exports /nfs/local and /nfs/home, and the client mounts /nfs/local read-only as /usr/local and /nfs/home read-write as /home. Because of this problem in some Linux versions, /home will actually be read-only, and no warnings issued, because the two directories by default have the same file system ID. By explicitly setting distinct file system IDs on the server (using the fsid option), this can be avoided.

### Part 2: The automounter ####################################################
# The automounter is a piece of software that mounts remote file systems automatically when they are accessed. The most common use of the automounter is to mount user home directories individually from several disk volumes or file servers, but it is sometimes used for e.g. removable media. In your small network, using an automounter is overkill, but you're going to do it anyway, for home directories.

# This lab (particularly troubleshooting) will be much easier if you understand how the automounter works. Spending some time on learning about the automounter can really pay off.

# How the automounter works
# The automounter intercepts accesses to the file systems it is configured to mount, and when an access takes place, it mounts the appropriate file system. For example, if you've set up the automounter to mount home directories, the automounter will intercept accesses to files in /home/username, and mount the appropriate file system as /home/username on access.

# The precise details of how the automounter works depends on the implementation. There are multiple implementations, all with similarities and differences. In Linux, using the kernel automounter (the most common choice), the automounter is controlled using the automount command. However, in most distributions (including Debian), the automount command is run by a /etc/init.d/autofs, which parses configuration files for the automounter. This is similar to how the Solaris automounter works.

# The autofs script can be used to control the automounter. Running /etc/init.d/autofs stop will stop the automounter and /etc/init.d/autofs status will show the current status of the automounter (including any mount points it is controlling).

# The autofs script parses a so-called master map, which lists other automounter maps to load. Each automounter map describes how file systems below a certain mountpoint (an existing directory, specified in the master map) are to be mounted.

# Note that the automounter "owns" any directory specified as a mount point in the master map. Any files or directories already in that directory will be hidden as long as the automounter is running. For example, if the /home directory contains local home directories for users, and you then start the automounter with /home as its mountpoint, then the local home directories will become inaccessible.

#### Automount maps, including the master map, can be stored in several different ways. By the time you complete this lab, you are expected to have all configuration in NIS (or LDAP, if that's what you're using). The location (NIS, LDAP, local file) of the master map can be specified in nsswitch.conf or /etc/default/autofs (depending on Debian version) and the location of all other maps can be specified in the master map.

### Exercise 4: Preparations ###################################################
# 4-1 If you have not completed the storage lab, do so now.
# see STO_(conf|test)

# 4-2 Create two new users, but move one user's home directory to /home2/USERNAME and the other user's home directory to /home1/USERNAME (you will probably have to create the /home1 and /home2 directories first). Ensure that no home directories remain in /home. Do not change the home directory location in the user database.
if [[ `uname -u` == "server" ]]; then
  # MOVE TO TESTS?
  users=( "matteus" "oscar" )
  for NAME in ${users[@]}; do
    addUser
    echo "${NAME}:${NAME}" | chpasswd
    cpFiles
  done
fi

### Report: Automated test cases that show that /home1 and /home2 are being exported with appropriate permissions.

# The use of /home1 and /home2 is fairly typical in larger systems, where the home directories of all users won't fit on a single disk. This is also the type of situation in which the automounter is really useful. Furthermore, it is easier to test the automounter in this configuration than it is when the server has all home directories in /home.

# [!] In the version of Debian we are using, nis may start after autofs, which is a problem if you keep your automount maps in nis (which you are supposed to do). In order to fix this, you need to reorder the boot sequence. The boot sequence for the default run level (2) is determined by the lexicographic order of the links in /etc/rc2.d. The link names are formatted as "S priority service". For example, cron starts at priority 89, so its link is named S89cron. The default for portmap is 18, and the default for autofs and nis is 19. You need to change the priority for portmap to 17 and the priority for nis to 18. That way, portmap will start before nis, which starts before autofs. The update-rc.d command can be used to accomplish this.

#update-rc.d -f service remove update-rc.d service defaults priority

##### Depending on the version of Debian you are using, some unexpected configuration may be required. In particular, some versions of Debian default to NFS version 4 in the automounter, even when the server does not support it. We recommend that you explicitly configure the automount maps so the automounter uses NFS version 3 by adding "-vers=3" between the key and the path in the automount maps.

### Exercise 5: Configure the automounter ######################################

# 5-3 Verify that all users can log on to the client and that the correct home directories are mounted.
## See NFS_test.sh
# Report: Automated test cases that show that the automounter is working properly.
## See NFS_test.sh

# Note that the only automounter configuration that may reside in local files on the client are configuration files that are guaranteed to never change when new automounts are added or old ones removed. In other words, the master map and any map it references must be stored in the directory service. If you have a single local configuration file, you probably have too many. If you have more than one, you definitely have too many.

# As a troubleshooting help, you may want to try running sh -x /etc/init.d/autofs restart to restart the automounter after reconfiguring it. The /etc/init.d/autofs script is responsible for reading the automount maps (configuration), and by using sh -x to invoke it, all commands that are used to read the configuration will be printed. You will be able to see exactly which files and NIS maps are consulted, and what automount commands are run.
/etc/init.d/autofs start
