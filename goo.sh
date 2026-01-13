#!/usr/bin/env bash

declare FOO="" THOST=""
readonly bn="$(basename "$0")"

main() {
  local -a Files=()
  mapfile -t Files < <(find . -maxdepth 2 -type f -name hosts);
  echo "files: ${Files[@]} | len: ${#Files[@]}"

  for (( i = 0; i < ${#Files[@]}; i++ )); do
    echo "$i. ${Files[i]};";
    cat ${Files[i]};
  done
  #cat ./inventory/hosts
}



main