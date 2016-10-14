#!/bin/bash
# 7-1 Write a script that can add users in bulk to your system. It needs to
# accept input consisting of one name per line. Names can contain multiple
# words, unusual characters, anything.

### CONFIG VARIABLES
# These are variables used throughout the script. Adjust to fit your desires.
CGROUPS="users"       # Comma-separated list of groups. Default: GROUPS=users
CSHELL="/bin/bash"    # Shell for added users. Default: /bin/bash
USUF=5                # Suffix Length in case of conflicting usernames
PWLENGTH=8            # Length of passwords generated

# Multi purpose variables ...
LOOP=true
DEBUG=

# Fluffy output ...
Bold=$(tput bold)
Underline=$(tput sgr 0 1)
Reset=$(tput sgr0)
# Regular Colors
Red=$(tput setaf 1)
Green=$(tput setaf 2)
Yellow=$(tput setaf 3)
Blue=$(tput setaf 4)
Purple=$(tput setaf 5)
Cyan=$(tput setaf 6)
White=$(tput setaf 7)
# Bold
BRed=${Bold}$(tput setaf 1)
BGreen=${Bold}$(tput setaf 2)
BYellow=${Bold}$(tput setaf 3)
BBlue=${Bold}$(tput setaf 4)
BPurple=${Bold}$(tput setaf 5)
BCyan=${Bold}$(tput setaf 6)
BWhite=${Bold}$(tput setaf 7)

error_msg() {
  local _msg="\n$1\n"
  echo -e "${Red}${_msg}${Reset}" >&2
  exit 1
}

## Do not uncomment until you are in a live environment.
#unset DEBUG
# a) Calculate a unique username for the user.
userGen() {
  # Check if user exists ... Returns UID or -1.
  if [ `id -u "$NAME"  2>/dev/null || echo -1` -ge 0 ]; then

    # If existing:
    # Generate a random string, append as USERNAME-STRING,
    # make sure it does not exist.
    while [ ${LOOP} = true ];
    do
      VALCHAR="a-z"
      NOCHARS=$USUF
      randomString
      NAME=${NAME}-"$RAND"
      if [ `id -u "$NAME" 2>/dev/null || echo -1` -eq -1 ]; then
         LOOP=false; else
          :
      fi
    done; LOOP=true
  fi

}

# b) Add the user to the system.
addUser() {
  # Add the users, default group being the same as the username and extra groups
  # (-G) defined in $CGROUPS, creating homedir (-m) and setting shell to $CSHELL (-s).
  ${DEBUG+printf "\n${Green}%s${Reset} %s" "unset DEBUG" "to add users "}
  ${DEBUG-useradds -m -G "$CGROUPS" -s "$CSHELL" "$NAME"}
}

# c) Generate a random password for the user.
pwGen() {
  NOCHARS=$PWLENGTH
  VALCHAR="a-zA-Z0-9!#%&?_-"
  randomString
  PASSWD="$RAND"
# Now, this might not work depending on passwd(1) version, due to safety reasons
# and so on, but as we're going to print it anyway later ...
  ${DEBUG+printf "%s\n" "and password!"}
  ${DEBUG-passwd "$NAME" --stdin <<< "$PASSWD"}
}

# d) Create the user's home directory and copy standard files to it.
cpFiles() {
  # User home directory created in addUser.
:
}

# e) Configure any services that need to be configured.
configServices() {
:
}

# f) Output the username and password on a single line.
printUser() {
printf "${Blue}%s${Reset} : ${Cyan}%s${Reset}\n" "$NAME" "$PASSWD"
}

randomString() {
  RAND=$(cat /dev/urandom | tr -dc ${VALCHAR} | fold -w $NOCHARS | head -n 1)
}

### MAIN SCRIPT STARTS HERE

# Make sure the file exists ...
if [[ $# -eq 0 ]] ; then
  error_msg "No user list-file assigned. ${Reset} Syntax: ${0} <filename>"
else
  if [ ! -f "$1" ]; then
    error_msg "The file $1 could not be found."
  fi
fi
if [[ "$(id -u)" != "0" ]]; then
  error_msg "ERROR! You must execute the script as the 'root' user."
fi
tput clear
printf "\n%s \n\n" "Welcome!"
printf "%s \n" "Uncomment 'unset DEBUG' in the script file to disable dry run."
printf "%s \n" "During a dry run, no permanent changes will be made to the system."
printf "%s \n" "Therefore, duplicate users can still be listed if not already present."

# This part is for testing purposes only.
if [ -z "$DEBUG-unset" ]; then
  printf "${BRed}%s${Reset} \n" "YOU ARE LIVE! CHANGES WILL BE MADE TO THE SYSTEM. PROCEED? ([N]/Y)"
  read -n1 LIVE
  LIVE=$(echo ${LIVE} | tr 'A-Z' 'a-z')
  if [ ! ${LIVE} == y ]; then
    exit 0
  fi
else
  printf "%s \n" "Starting dry run ..."
fi
# End of dry-run option.

# Read the usernames from file.
while read NAME; do
  # Remove sucky characters and make it all nice lowercase.
  NAME=$( echo "$NAME" | tr 'A-Z' 'a-z' | sed 's/[^ab-z]//g')

  # Do magic!
  userGen
  addUser
  pwGen
  # cpFiles
  # configServices
  printUser

done < $1

# No user input apart from the list of names is allowed. The script may need to
# do other things as well. Part of your job is to figure out what. Your script
# also needs to be as fast as possible. Anything that can be done once for the
# entire run should be done only once (e.g. restarting certain services).

# Data files for testing are available in /home/TDDI09.

# Report: After the last lab, hand in your script. You will have to demonstrate it as well.
