#!/usr/bin/env bash

if [[ $- != *i* ]]; then
  echo "No interactive mode, enable -o nounset, errtrace, pipefail."
  set -o nounset
  set -o errtrace
  set -o pipefail
fi

# TODO add fail fast.
declare LOGIN="root" AS_PYENV=1 THOST="" VERBOSE="" VAULT="" TEMPLATE="./core/plays/vds-init.yml.tmpl"
export LOGIN
typeset -i DRY=0

# constants begin
readonly PLAYBOOK="vds-init.yml"
readonly PY_ENV_PATH="./.venv/bin/activate"
readonly bn="$(basename "$0")"
# constants end

echo "starting script as: ${LOGIN}"

main() {
  local fn=${FUNCNAME[0]}
  local TEMPLATE="./core/plays/$PLAYBOOK.tmpl"
  echo_info "Template: $TEMPLATE"

  local b="" v="" k=""

  if [[ $LOGIN != "root" ]]; then
    b="--become"
  fi

  if (( VERBOSE )); then
    v="-"
    while (( VERBOSE )); do
      v="${v}v";
      (( VERBOSE-- ));
    done
  fi

  envsubst < "$TEMPLATE" > "$PLAYBOOK"
  if [[ $AS_PYENV == 1 ]]; then
    source $PY_ENV_PATH
    echo_info "Running as python_env(as_pyenv = $AS_PYENV): $(python --version)";
  fi

  if (( ! DRY )); then
    echo "Executing cmd: ansible-playbook -i ./inventory/hosts "--limit=$THOST" "$PLAYBOOK" $VAULT $b $v --diff --force-handlers"
    ansible-playbook -i inventory/hosts "--limit=$THOST" "$PLAYBOOK" $VAULT $b $v --diff --force-handlers
  fi

  if [[ $AS_PYENV == 1 ]]; then
    deactivate
  fi
  echo "done for $PLAYBOOK"
}

usage() {
  echo -e "\\n    Usage: $bn [OPTIONS] <target_group>\\n
    Options:

    -J, --ask-vault-pass    vault password
    -n, --dry-run		        no make action, print out command only, assemble playbook
    -h, --help			        print help
    -v, --verbose           run ansible-playbook with more detailed output

    target_host			        DNS name of a target host
"
}

if ! TEMP=$(getopt -o Jnhv --longoptions ask-vault-pass,help,dry-run -n "$bn" -- "$@")
  then
      echo "Terminating..." >&2
      exit 1
fi

eval set -- "$TEMP"
unset TEMP

while true;  do
  case $1 in
   -J|--ask-vault-pass) VAULT="-J"; shift ;;
   -h|--help) usage; exit 0;;
   -n|--dry-run) DRY=1; shift ;;
   -v|--verbose) ((VERBOSE++)); shift ;;
      *) shift; break ;;
  esac
done

if [[ "${1:-}" == "" ]]; then
  echo "Error: Must provide hostname to start $bn" >&2;
  exit 1;
fi

export THOST=$1;

readonly C_RST="tput sgr0"
readonly C_RED="tput setaf 1"
readonly C_GREEN="tput setaf 2"
readonly C_YELLOW="tput setaf 3"
readonly C_BLUE="tput setaf 4"
readonly C_CYAN="tput setaf 6"
readonly C_WHITE="tput setaf 7"

echo_info() { $C_CYAN; echo "$*"; $C_RST; }

echo_info "executing for: $THOST"
main
