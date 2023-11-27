#!/usr/bin/env bash
# This script was generated by rargs 0.0.0 (https://rargs.cloudbridge.uy)
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
      -p | --protocol)
        rargs_protocol="$2"
        shift 2
        ;;
      -u | --user)
        rargs_user="$2"
        shift 2
        ;;
      -?*)
        printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option: " "$key" >&2
        exit 1
        ;;
      *)
        if [[ -z "$rargs_region" ]]; then
          rargs_region=$key
          shift
        elif [[ -z "$rargs_environment" ]]; then
          rargs_environment=$key
          shift
        else
          printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid argument: " "$key" >&2
          exit 1
        fi
        ;;
    esac
  done
}

root() {
  local rargs_protocol
  local rargs_user
  local rargs_region
  local rargs_environment
  # Parse command arguments
  parse_root "$@"

  
  if [[ -z "$rargs_protocol" ]]; then
    rargs_protocol="ssh"
  fi
  if [[ -z "$rargs_environment" ]]; then
    rargs_environment="development"
  fi
  
  if [[ -n "$rargs_protocol" ]]; then
    if [[ ! "(ssh ftp http)" =~ $rargs_protocol ]]; then
      printf "\e[31m%s\e[33m%s\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option for " "protocol" ": " "$rargs_protocol" >&2
      usage >&2
      exit 1
    fi
  fi
  if [[ -n "$rargs_user" ]]; then
    if [[ ! "(user admin)" =~ $rargs_user ]]; then
      printf "\e[31m%s\e[33m%s\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option for " "user" ": " "$rargs_user" >&2
      usage >&2
      exit 1
    fi
  fi
  if [[ -n "$rargs_region" ]]; then
    if [[ ! "(eu us)" =~ $rargs_region ]]; then
      printf "\e[31m%s\e[33m%s\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option for " "region" ": " "$rargs_region" >&2
      usage >&2
      exit 1
    fi
  fi
  if [[ -n "$rargs_environment" ]]; then
    if [[ ! "(development staging production)" =~ $rargs_environment ]]; then
      printf "\e[31m%s\e[33m%s\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option for " "environment" ": " "$rargs_environment" >&2
      usage >&2
      exit 1
    fi
  fi
  
  if [[ -z "$rargs_user" ]]; then
    printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Missing required option: " "user" >&2
    usage >&2
    exit 1
  fi
  if [[ -z "$rargs_region" ]]; then
    printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Missing required option: " "region" >&2
    usage >&2
    exit 1
  fi
	inspect_args
}


normalize_rargs_input() {
  local arg flags

  while [[ $# -gt 0 ]]; do
    arg="$1"
    if [[ $arg =~ ^(--[a-zA-Z0-9_\-]+)=(.+)$ ]]; then
      rargs_input+=("${BASH_REMATCH[1]}")
      rargs_input+=("${BASH_REMATCH[2]}")
    elif [[ $arg =~ ^(-[a-zA-Z0-9])=(.+)$ ]]; then
      rargs_input+=("${BASH_REMATCH[1]}")
      rargs_input+=("${BASH_REMATCH[2]}")
    elif [[ $arg =~ ^-([a-zA-Z0-9][a-zA-Z0-9]+)$ ]]; then
      flags="${BASH_REMATCH[1]}"
      for ((i = 0; i < ${#flags}; i++)); do
        rargs_input+=("-${flags:i:1}")
      done
    else
      rargs_input+=("$arg")
    fi

    shift
  done
}

inspect_args() {
  prefix="rargs_"
  args="$(set | grep ^$prefix | grep -v rargs_run || true)"
  if [[ -n "$args" ]]; then
    echo
    echo args:
    for var in $args; do
      echo "- $var" | sed 's/=/ = /g'
    done
  fi

  if ((${#deps[@]})); then
    readarray -t sorted_keys < <(printf '%s\n' "${!deps[@]}" | sort)
    echo
    echo deps:
    for k in "${sorted_keys[@]}"; do echo "- \${deps[$k]} = ${deps[$k]}"; done
  fi

  if ((${#other_args[@]})); then
    echo
    echo other_args:
    echo "- \${other_args[*]} = ${other_args[*]}"
    for i in "${!other_args[@]}"; do
      echo "- \${other_args[$i]} = ${other_args[$i]}"
    done
  fi
}

version() {
  echo "0.0.1"
}
usage() {
  printf "Sample showing the use of arg and option whitelist (allowed values)\n"
  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  whitelist -u|--user <USER> [OPTIONS] REGION [ENVIRONMENT] \n"
  printf "  whitelist -h|--help\n"
  printf "  whitelist -v|--version\n"
  printf "\n\033[4m%s\033[0m\n" "Arguments:"
  printf "  REGION\n"
  printf "    Region to connect to\n"
  printf "    [@required, @choices eu, us]\n"
  printf "  ENVIRONMENT\n"
  printf "    Environment to connect to\n"
  printf "    [@default development, @choices development, staging, production]\n"

  printf "\n\033[4m%s\033[0m\n" "Options:"
  printf "  -p --protocol [<PROTOCOL>]\n"
  printf "    Protocol to connect with\n"
  printf "    [@default ssh, @choices ssh, ftp, http]\n"
  printf "  -u --user <USER>\n"
  printf "    User name\n"
  printf "    [@choices user, admin]\n"
  printf "  -h --help\n"
  printf "    Print help\n"
  printf "  -v --version\n"
  printf "    Print version\n"
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "${1:-}" in
      -v|--version)
        version
        exit
        ;;
      -h|--help)
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
    -h|--help)
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

rargs_run() {
  declare -A deps=()
  declare -a rargs_input=()
  normalize_rargs_input "$@"
  parse_arguments "${rargs_input[@]}"
  root "${rargs_input[@]}"
}

rargs_run "$@"
