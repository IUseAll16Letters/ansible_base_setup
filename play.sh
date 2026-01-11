#!/usr/bin/env bash

if [[ $- != *i* ]]; then
  echo "No interactive mode, enable -o nounset, errtrace, pipefail"
  set -o nounset
  set -o errtrace
  set -o pipefail
fi

declare LOGIN="" AS_PYENV=1 verbose=""
LOGIN="$(whoami)"

# constants begin
readonly TEMPLATE="./core/plays/play.yml.tmpl"
readonly PLAYBOOK="play.yml"
readonly PY_ENV_PATH="./.venv/bin/activate"
# constants end

declare LOGIN="$(whoami)"
echo "starting script as: ${LOGIN}"

main() {
  local b="" v=""

  if [[ $LOGIN == "root" ]]; then
    b="--become"
  fi
#  echo "$b <<< become | $inventory < inventory";
  envsubst <"$TEMPLATE" >"$PLAYBOOK"
  if [[ $AS_PYENV == 1 ]]; then
    source $PY_ENV_PATH
    echo_info "Running as python_env($AS_PYENV): $(python --version)";
  fi

  ansible-playbook $b $v "$PLAYBOOK"

  if [[ $AS_PYENV == 1 ]]; then
    deactivate
  fi
  echo "done for $PLAYBOOK"
}

readonly C_RST="tput sgr0"
readonly C_RED="tput setaf 1"
readonly C_GREEN="tput setaf 2"
readonly C_YELLOW="tput setaf 3"
readonly C_BLUE="tput setaf 4"
readonly C_CYAN="tput setaf 6"
readonly C_WHITE="tput setaf 7"

echo_info() { $C_CYAN; echo "$*"; $C_RST; }

main
