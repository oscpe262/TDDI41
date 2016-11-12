#!/bin/bash
[[ ! -f NETtest.sh ]] && echo -e "Missing dependency: NETtest.sh" && exit 1
source NETtest.sh

tests() {
  echo "Running some tests omg!"
}
