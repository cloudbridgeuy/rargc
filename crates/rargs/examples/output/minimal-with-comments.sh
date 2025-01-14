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
      -f | --force)
        rargs_force=1
        shift
        ;;
      -?*)
        printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option: " "$key" >&2
        exit 1
        ;;
      *)
        if [[ -z "$rargs_source" ]]; then
          rargs_source=$key
          shift
        elif [[ -z "$rargs_target" ]]; then
          rargs_target=$key
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
  local rargs_force
  local rargs_source
  local rargs_target

  # Parse command arguments
  parse_root "$@"

  
  if [[ -z "$rargs_source" ]]; then
    printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Missing required option: " "source" >&2
    usage >&2
    exit 1
  fi
	echo "${rargs_input[*]}"
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

# This line comment will be added to the final script
# Comments that begin with a double hash will be added to the final script
# Comments that are included before a @cmd tag will be considered root comments, and be hoisted to
# the top of the script. If you want your comments to be available near the function definition,
# place them after the @cmd tag.
version() {
  echo -n "0.0.1"
}
usage() {
  printf "Sample minimal application without commands\n"
  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  minimal [OPTIONS] [COMMAND] [COMMAND_OPTIONS]\n"
  printf "  minimal -h|--help\n"
  printf "  minimal -v|--version\n"
  printf "\n\033[4m%s\033[0m\n" "Examples:"
  printf "  minimal example.com\n"
  printf "    Download a file from the internet\n"
  printf "  minimal example.com ./output -f\n"
  printf "    Download a file from the internet and force save it to ./output\n"
  printf "\n\033[4m%s\033[0m\n" "Arguments:"
  printf "  SOURCE\n"
  printf "    URL to download from\n"
  printf "    [@required]\n"
  printf "  TARGET\n"
  printf "    Target filename (default: same as source)\n"
  printf "\n\033[4m%s\033[0m\n" "Commands:"
  cat <<EOF
  download .... Download a file
EOF

  printf "\n\033[4m%s\033[0m\n" "Options:"
  printf "  -f --force\n"
  printf "    Overwrite existing files\n"
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
    d|down|download)
      action="download"
      rargs_input=("${rargs_input[@]:1}")
      ;;
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
download_usage() {
  printf "Download a file\n"
  printf "\n\033[4m%s\033[0m %s\n" "Alias:" "d, down"

  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  download [OPTIONS] SOURCE [TARGET]\n"
  printf "  download -h|--help\n"
  printf "\n\033[4m%s\033[0m\n" "Examples:"
  printf "  download download example.com\n"
  printf "    Download a file from the internet\n"
  printf "  download download example.com ./output -f\n"
  printf "    Download a file from the internet and force save it to ./output\n"
  printf "\n\033[4m%s\033[0m\n" "Arguments:"
  printf "  SOURCE\n"
  printf "    URL to download from\n"
  printf "    [@required]\n"
  printf "  TARGET\n"
  printf "    Target filename (default: same as source)\n"

  printf "\n\033[4m%s\033[0m\n" "Options:"
  printf "  -f --force\n"
  printf "    Overwrite existing files\n"
  printf "  -h --help\n"
  printf "    Print help\n"
}
parse_download_arguments() {
  while [[ $# -gt 0 ]]; do
    case "${1:-}" in
      -h|--help)
        download_usage
        exit
        ;;
      *)
        break
        ;;
    esac
  done

  while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
      -f | --force)
        rargs_force=1
        shift
        ;;
      -?*)
        printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option: " "$key" >&2
        exit 1
        ;;
      *)
        if [[ -z "$rargs_source" ]]; then
          rargs_source=$key
          shift
        elif [[ -z "$rargs_target" ]]; then
          rargs_target=$key
          shift
        else
          printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid argument: " "$key" >&2
          exit 1
        fi
        ;;
    esac
  done
}
# Download a file
# This comment will be placed on top of the function definition.
download() {
  local rargs_force
  local rargs_source
  local rargs_target

  # Parse command arguments
  parse_download_arguments "$@"

  
  if [[ -z "$rargs_source" ]]; then
    printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Missing required option: " "source" >&2
    download_usage >&2
    exit 1
  fi
	echo "${rargs_input[*]}"
	bottom
}

rargs_run() {
  declare -a rargs_input=()
  normalize_rargs_input "$@"
  parse_arguments "${rargs_input[@]}"
  # Call the right command action
  case "$action" in
    "download")
      download "${rargs_input[@]}"
      exit
      ;;
    root)
      root "${rargs_input[@]}"
      exit
      ;;
    "")
      root "${rargs_input[@]}"
      ;;
    
  esac
}

rargs_run "$@"
