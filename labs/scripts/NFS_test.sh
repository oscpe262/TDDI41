#!/bin/bash
source common.sh
# 4-2 Create two new users, but move one user's home directory to /home2/USERNAME and the other user's home directory to /home1/USERNAME (you will probably have to create the /home1 and /home2 directories first). Ensure that no home directories remain in /home. Do not change the home directory location in the user database.
retval=0

if [[ `uname -n` == "server" ]]; then
  pkginstall "sshpass"
  users=( "matteus" "oscar" )
  /etc/init.d/autofs stop
  # add users and update nis
  for NAME in ${users[@]}; do
    techo "Add ${Yellow}$NAME${Reset}"
    addUser &
    pid=$! ; progress $pid
    [[ $? -ne 0 ]] && ((retval++))

    # of course, this isn't secure at all, but as we will delete the accounts in a few moments ...
    techo "Set ${Yellow}passwd${Reset}"
    echo "${NAME}:${NAME}" | chpasswd &
    pid=$! ; progress $pid
    [[ $? -ne 0 ]] && ((retval++))

    techo "Files for ${Yellow}$NAME${Reset}"
    cpFiles &
    pid=$! ; progress $pid
    [[ $? -ne 0 ]] && ((retval++))
  done

  /etc/init.d/autofs stop
  techo "${Yellow}NIS${Reset} restart"
  nisrestart 1&> /dev/null &
  pid=$! ; progress $pid
  [[ $? -ne 0 ]] && ((retval++))

# no entries in /home
  [[ `ls /home | wc -l` -ne 0 ]] && ((retval++))

  # test home dir mounts
  for NAME in ${users[@]}; do
    techo "Logging in to ${Yellow}${NAME}${Reset}"
    sshpass -p ${NAME} ssh $NAME@$c2 /home/$NAME/NFS_test.sh &> /dev/null &
    pid=$! ; progress $pid
    [[ $? -ne 0 ]] && ((retval++))
  done


  for NAME in ${users[@]}; do
    [[ `id -u "$NAME"  2>/dev/null || echo -1` -lt 0 ]] && continue
    techo "Removing user ${Yellow}$NAME${Reset}"
    userdel $NAME &
    pid=$! ; progress $pid
    [[ -d /home1/$NAME ]] && rm -rf /home1/$NAME
    [[ -d /home2/$NAME ]] && rm -rf /home2/$NAME
    sed -i "/${NAME}/d" /etc/auto.home
  done

  techo "${Yellow}NIS${Reset} restart"
  nisrestart 1&> /dev/null &
  pid=$! ; progress $pid

  exit $retval
fi

# 5-3 Verify that all users can log on to the client and that the correct home directories are mounted.
if [[ ! `uname -n` == "server" ]]; then
  USER="`whoami`"
  [[ ! $USER == "matteus" ]] && [[ ! $USER == "oscar" ]] && ((retval++))
  [[ ! `pwd` == "/home/$USER" ]] && ((retval++))
  exit $retval
fi
