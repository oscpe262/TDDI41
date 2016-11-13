#!/bin/bash
#[[ ! -f common.sh ]] && echo -e "Missing dependency: common.sh" && exit 1
#source common.sh

DRYRUN=1
dry_ok() {
  cecho "${Blue}Dryrun!${Reset}"
}

randomString() {
  RAND=$(cat /dev/urandom | tr -dc ${VALCHAR} | fold -w $NOCHARS | head -n 1)
}

userGen() {
  local _LOOP=true
  # Check if user exists ... Returns UID or -1.
  if [ `id -u "$NAME"  2>/dev/null || echo -1` -ge 0 ]; then

    # If existing:
    # Generate a random string, append as USERNAME-STRING,
    # make sure it does not exist.
    while [ ${_LOOP} = true ];
    do
      VALCHAR="a-z"
      NOCHARS=$USUF
      randomString
      NAME="${NAME}-${RAND}"
      if [ `id -u "$NAME" 2>/dev/null || echo -1` -eq -1 ]; then
         _LOOP=false
      fi
    done
  fi
  echo -ne "$NAME" > /dev/shm/name
}

addUser() {
  # Add the users, default group being the same as the username and extra groups
  # (-G) defined in $CGROUPS, creating homedir (-m) and setting shell to $CSHELL (-s).
  #echo -e "\baddUser $NAME"
  [[ $DRYRUN -eq 0 ]] && useradd -m -G ${CGROUPS} -s ${CSHELL} ${NAME} 2>${LOG}
}

pwGen() {
  NOCHARS=$PWLENGTH
  VALCHAR="a-zA-Z0-9!#%&?_-"
  randomString
  PASSWD=${RAND}
  echo -ne "$PASSWD" > /dev/shm/name

# This isn't very safe, but as we're going to print it anyway later ...
  [[ $DRYRUN -eq 0 ]] && echo "${NAME}:${PASSWD}" | chpasswd 2>${LOG}
}

cpFiles() {
  for f in ${CPHOME[@]}; do
    echo -e "cp -r ${f} /home/${NAME}/$(basename ${f})" >> $LOG
    [[ $DRYRUN -eq 0 ]] && cp -r ${f} /home/${NAME}/$(basename ${f}) 2>${LOG}
  done

  for t in ${TOUCH[@]}; do
    echo -e "touch /home/${NAME}/${t}" >> $LOG
    [[ $DRYRUN -eq 0 ]] && touch /home/${NAME}/${t} 2>${LOG}
  done
}

reclaim() {
  [[ $DRYRUN -eq 0 ]] && chown -R $NAME:$NAME /home/$NAME/ 2>${LOG}
}

configServices() {
:
}
