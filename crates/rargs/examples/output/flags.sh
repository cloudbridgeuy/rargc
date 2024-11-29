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
      --falsy)
        rargs_falsy=1
        shift
        ;;
      -s | --shorty)
        rargs_shorty=1
        shift
        ;;
      -no-s | --no-shorty)
        rargs_shorty=""
        shift
        ;;
      --truthy)
        rargs_truthy=1
        shift
        ;;
      --no-truthy)
        rargs_truthy=""
        shift
        ;;
      -v | --verbose)
        if [[ -z "$rargs_verbose" ]]; then
          rargs_verbose=1
        else
          rargs_verbose=$(("$rargs_verbose" + 1))
        fi
        shift
        ;;
      -?*)
        printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option: " "$key" >&2
        exit 1
        ;;
      *)
        if [[ "$key" == "" ]]; then
          break
        fi
        printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid argument: " "$key" >&2
        exit 1
        ;;
    esac
  done
}

root() {
  local rargs_falsy
  local rargs_shorty
  local rargs_truthy
  local rargs_verbose

  if [[ -z "$rargs_shorty" ]]; then
    rargs_shorty="1"
  fi
  if [[ -z "$rargs_truthy" ]]; then
    rargs_truthy="1"
  fi
  # Parse command arguments
  parse_root "$@"

	if [[ -z "$rargs_verbose" ]]; then
		if [[ -n "$rargs_falsy" ]]; then
			echo "falsy == $rargs_falsy"
		else
			echo "falsy == false"
		fi
		if [[ -n "$rargs_truthy" ]]; then
			echo "truthy == $rargs_truthy"
		else
			echo "truthy == false"
		fi
		if [[ -n "$rargs_shorty" ]]; then
			echo "shorty == $rargs_shorty"
		else
			echo "shorty == false"
		fi
	else
		echo "verbose == $rargs_verbose"
	fi
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

version() {
  echo -n "0.0.1"
}
usage() {
  printf "Flags examples\n"
  
  printf "\n"
  printf "This script shows different ways of working with truthy or falsy flags.\n"
  printf "By default, flags are truthy if they are passed as an option, and empty\n"
  printf "otherwise. If you would like your flag to be true by default, provide a\n"
  printf "default value when defining the flag. This will enable the ability to\n"
  printf "provide a negated version of the flag, using a '--no-' or '-n-' prefix\n"
  printf "for the long and short version of the flag.\n"
  printf "\n"
  printf "This script exposes three flags that showcase this behavior.\n"
  printf "\n"
  printf "  1. \`falsy\` : Default flag that is set to \`false\` by default.\n"
  printf "  2. \`truthy\`: Flag with a default value that is considered \`truthy\`\n"
  printf "               by default.\n"
  printf "  3. \`shorty\`: Same as the \`truthy\` flag but configured to also use\n"
  printf "               a short version of the flag.\n"
  printf "\n"
  printf "You can also define flags to be multiple, in which case the value of\n"
  printf "calling the flag multiple time will be an integer with the total count\n"
  printf "flags provided to the command.\n"
  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  minimal [OPTIONS]\n"
  printf "  minimal -h|--help\n"
  printf "  minimal --version\n"
  printf "\n\033[4m%s\033[0m\n" "Examples:"
  printf "  minimal --falsy\n"
  printf "    Set the \`falsy\` flag to \`true\`\n"
  printf "  minimal --no-truthy\n"
  printf "    Set the \`truthy\` flag to \`false\`\n"
  printf "  minimal --no-shorty\n"
  printf "    Set the \`shorty\` flag to \`false\`\n"
  printf "  minimal -n-s\n"
  printf "    Set the \`shorty\` flag to \`false\` using the short name\n"
  printf "  minimal -vvv\n"
  printf "    Return the total count of the multiple flag\n"
  printf "  minimal --verbose --verbose --verbose\n"
  printf "    Same example as before but with the full value\n"

  printf "\n\033[4m%s\033[0m\n" "Options:"
  printf "  --falsy\n"
  printf "    Falsy flag\n"
  printf "  -no-s --no-shorty\n"
  printf "    Shorty flag\n"
  printf "  --no-truthy\n"
  printf "    Truthy flag\n"
  printf "  -v --verbose\n"
  printf "    Support multiple verbose flags\n"
  printf "    [@multiple]\n"
  printf "  -h --help\n"
  printf "    Print help\n"
  printf "  --version\n"
  printf "    Print version\n"
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "${1:-}" in
      --version)
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
  declare -a rargs_input=()
  normalize_rargs_input "$@"
  parse_arguments "${rargs_input[@]}"
  root "${rargs_input[@]}"
}

rargs_run "$@"