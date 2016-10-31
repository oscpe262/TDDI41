# include if exists in current path
if [[ -f `pwd`/filename ]]; then
  source filename
fi

# if variable is empty string
if [[ -z $VAR ]]; then
  :
fi

# if running with flag, set variable 1
[[ $1 == -v || $1 == --verbose ]] && VAR=1 || VAR=0

# line across term
printf "%$(tput cols)s\n"|tr ' ' '-'

# root check
[[ "$(id -u)" == "0" ]] && echo -e "is root"

# iterate over letter
for LETTER in {a..g}; do; echo -e ${LETTER}; done
