#!/bin/bash
TMP=$(basename $0).tmp
TARGET="runme.sh"

[[ -f $TMP ]] && rm $TMP
[[ -f $TARGET ]] && rm $TARGET

extract() {
  local file
  local tail
  local head
  local temp
  file=$1
  [[ -z $2 ]] && tail=1 || tail=$(( $(sed -n "/${2}/=" $file | head -n 1) ))
  [[ -z $3 ]] && temp="EOF" || temp=${3}
  head=$(( $(sed -n "/${temp}/=" $file | head -n 1) - $tail ))

  cat $file | tail -n +$tail | head -n $head >> $TMP
}

extract "tddi41.sh" "" "INCLUDE DEPENDENCIES"
extract "common.sh" "FORCE_EXIT" "SUPPORT FUNCS"
extract "SCT7.sh" "declare -A USERS" "SCT7_funcs"
extract "common.sh" "SUPPORT FUNCS" "EOF"
extract "SCT7_funcs.sh" "FUNCS"
extract "NET_funcs.sh" "defpingc"
extract "SCT7.sh" "MAIN SCRIPT"
extract "NETtest.sh" "NET TEST"
extract "tests.sh" "TESTS BRANCH"
extract "configs.sh" "CONFIGS BRANCH"
extract "tddi41.sh" "MAIN VARIABLES"

cp $TMP $TARGET && chmod +x $TARGET
rm $TMP
exit 0
