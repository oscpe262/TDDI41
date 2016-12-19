#!/bin/bash
source common.sh
### Delete users where 1000 < uid < 65000 ######################################
for user in `cat /etc/passwd | sed 's/:.*//g'`; do
  uid=`id -u $user`
  if [[ $uid -ge 1000 ]]; then
    if [[ $uid -lt 65000 ]]; then
      userdel -rf $user
      rm -rf /home{1,2}/$user
      sed -i "/${user}\t/d" /etc/auto.home
    fi
  fi
done
nisrestart
