#!/usr/bin/env bash
# This script was generated by rargc 0.0.0 (https://rargc.cloudbridge.uy)
# Modifying it manually is not recommended

if [[ "${BASH_VERSINFO:-0}" -lt 4 ]]; then
  printf "bash version 4 or higher is required\n" >&2
  exit 1
fi

if [[ -n "${DEBUG:-}" ]]; then
  set -x
fi

set -e

parse_root() {

  while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
      -v | --verbose)
        args['--verbose']=1
        shift
        ;;
      -h | --host)
        args['host']=$2
        shift 2
        ;;
      -?*)
        printf "invalid option: %s\n" "$key" >&2
        exit 1
        ;;
      *)
        printf "Invalid argument: %s\n" "$key" >&2
        exit 1
        ;;
    esac
  done
}
root() {

  echo "# this file is located in './crates/rargc/examples/output.sh'"
  echo "# you can edit it freely and regenerate (it will not be overwritten)"
  inspect_args
}



normalize_input() {
  local arg flags

  while [[ $# -gt 0 ]]; do
    arg="$1"
    if [[ $arg =~ ^(--[a-zA-Z0-9_\-]+)=(.+)$ ]]; then
      input+=("${BASH_REMATCH[1]}")
      input+=("${BASH_REMATCH[2]}")
    elif [[ $arg =~ ^(-[a-zA-Z0-9])=(.+)$ ]]; then
      input+=("${BASH_REMATCH[1]}")
      input+=("${BASH_REMATCH[2]}")
    elif [[ $arg =~ ^-([a-zA-Z0-9][a-zA-Z0-9]+)$ ]]; then
      flags="${BASH_REMATCH[1]}"
      for ((i = 0; i < ${#flags}; i++)); do
        input+=("-${flags:i:1}")
      done
    else
      input+=("$arg")
    fi

    shift
  done
}

inspect_args() {
  if ((${#args[@]})); then
    readarray -t sorted_keys < <(printf '%s\n' "${!args[@]}" | sort)
    echo args:
    for k in "${sorted_keys[@]}"; do echo "- \${args[$k]} = ${args[$k]}"; done
  else
    echo args: none
  fi
}


version() {
  echo "0.0.1"
}

usage() {
  printf "Example that replaces the default behavior of -v and -h\n"
  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  minus-v [OPTIONS]\n"
  printf "  minus-v --help\n"
  printf "  minus-v --version\n"
  printf "\n\033[4m%s\033[0m\n" "Examples:"
  printf "  minus-v -h|--host localhost\n"
  printf "    Set host\n"
  printf "  minus-v -v|--verbose\n"
  printf "    Set verbose mode on\n"

  printf "\n\033[4m%s\033[0m\n" "Options:"
  printf "  -h --host [<HOST>]\n"
  printf "    Show verbose output\n"
  printf "  -v --verbose\n"
  printf "    Show verbose output\n"
  printf "  --help\n"
  printf "    Print help\n"
  printf "  --version\n"
  printf "    Pring version\n"
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "${1:-}" in
      --version)
        version
        exit
        ;;
      --help)
        usage
        exit
        ;;
      *)
        break
        ;;
    esac
  done
  action="${1:-}"

  case $action in
    --help)
      usage
      exit
      ;;
    "")
      action="root"
      ;;
    *)
      action="root"
      ;;
  esac
}

run() {
  declare -A args=()
  declare -a input=()
  normalize_input "$@"
  parse_arguments "${input[@]}"
  parse_root "${input[@]}"
  root
}

run "$@"
