#!/usr/bin/env bash

if [[ $- != *i* ]]; then
  echo "No interactive mode, enable -o nounset, errtrace, pipefail."
  set -o nounset
  set -o errtrace
  set -o pipefail
fi

declare LOGIN="" AS_PYENV=1 verbose="" BECOME="" THOST=""
typeset -i DRY=0
LOGIN="$(whoami)"

# constants begin
readonly TEMPLATE="./core/plays/play.yml.tmpl"
readonly PLAYBOOK="play.yml"
readonly PY_ENV_PATH="./venv_ansible/bin/activate"
readonly bn="$(basename "$0")"
# constants end

declare LOGIN="$(whoami)"
echo "starting script as: ${LOGIN}"

main() {
  local b="" v="" k=""

  if [[ $LOGIN == "root" ]]; then
    b="--become"
  fi

  envsubst <"$TEMPLATE" >"$PLAYBOOK"
  if [[ $AS_PYENV == 1 ]]; then
    source $PY_ENV_PATH
    echo_info "Running as python_env(as_pyenv = $AS_PYENV): $(python --version)";
  fi

  if (( ! DRY )); then
    ansible-playbook $b $v "$PLAYBOOK" $BECOME
  fi

  if [[ $AS_PYENV == 1 ]]; then
    deactivate
  fi
  echo "done for $PLAYBOOK"
}

if ! TEMP=$(getopt -o Kn --longoptions dry-run,ask-become-pass -n "$bn" -- "$@")
  then
      echo "Terminating..." >&2
      exit 1
fi

echo "this is temp $TEMP"
eval set -- "$TEMP"
unset TEMP

while true;  do
  case $1 in
   -K|--ask-become-pass) BECOME="-K"; shift ;;
   -n|--dry-run) DRY=1; shift ;;
      *) shift; break ;;
  esac
done

$THOST="${1:-NOP}"

echo "THO: $THOST"

readonly C_RST="tput sgr0"
readonly C_RED="tput setaf 1"
readonly C_GREEN="tput setaf 2"
readonly C_YELLOW="tput setaf 3"
readonly C_BLUE="tput setaf 4"
readonly C_CYAN="tput setaf 6"
readonly C_WHITE="tput setaf 7"

echo_info() { $C_CYAN; echo "$*"; $C_RST; }

#main
