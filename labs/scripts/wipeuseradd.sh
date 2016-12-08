#!/bin/bash
### Delete users where 1000 < uid < 65000 ######################################
for user in `cat /etc/passwd | sed 's/:.*//g'`; do
  uid=`id -u $user`
  if [[ $uid -ge 1000 ]]; then
    [[ $uid -lt 65000 ]] && userdel -rf $user
  fi
done
