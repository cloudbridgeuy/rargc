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

  if ((${#rargs_other_args[@]})); then
    echo
    echo rargs_other_args:
    echo "- \${rargs_other_args[*]} = ${rargs_other_args[*]}"
    for i in "${!rargs_other_args[@]}"; do
      echo "- \${rargs_other_args[$i]} = ${rargs_other_args[$i]}"
    done
  fi
}

version() {
  echo "0.0.1"
}
usage() {
  printf "Sample application that uses the default command option\n"
  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  commands [OPTIONS] [COMMAND] [COMMAND_OPTIONS]\n"
  printf "  commands -h|--help\n"
  printf "  commands -v|--version\n"
  printf "\n\033[4m%s\033[0m\n" "Examples:"
  printf "  commands \n"
  printf "    Run the default command\n"
  printf "  commands --help\n"
  printf "    Print the global help\n"
  printf "  commands download something\n"
  printf "    Download something\n"
  printf "  commands upload something\n"
  printf "    Upload something\n"
  printf "  commands something\n"
  printf "    Upload something using the default command\n"
  printf "\n\033[4m%s\033[0m\n" "Commands:"
  cat <<EOF
  download .... Download a file
  upload ...... Upload a file
EOF
  printf "  [@default upload]\n"

  printf "\n\033[4m%s\033[0m\n" "Options:"
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
    d|download)
      action="download"
      rargs_input=("${rargs_input[@]:1}")
      ;;
    u|upload)
      action="upload"
      rargs_input=("${rargs_input[@]:1}")
      ;;
    -h|--help)
      usage
      exit
      ;;
    "")
      ;;
    *)
      action="upload"
      ;;
  esac
}
download_usage() {
  printf "Download a file\n"
  printf "\n\033[4m%s\033[0m %s\n" "Alias:" "d"

  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  download [OPTIONS] SOURCE\n"
  printf "  download -h|--help\n"
  printf "\n\033[4m%s\033[0m\n" "Arguments:"
  printf "  SOURCE\n"
  printf "    URL to download from\n"
  printf "    [@required]\n"

  printf "\n\033[4m%s\033[0m\n" "Options:"
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
      -?*)
        printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option: " "$key" >&2
        exit 1
        ;;
      *)
        if [[ -z "$rargs_source" ]]; then
          rargs_source=$key
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
download() {
  local rargs_source
  # Parse command arguments
  parse_download_arguments "$@"

  
  if [[ -z "$rargs_source" ]]; then
    printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Missing required option: " "source" >&2
    download_usage >&2
    exit 1
  fi
  inspect_args
}
upload_usage() {
  printf "Upload a file\n"
  printf "\n\033[4m%s\033[0m %s\n" "Alias:" "u"

  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  upload [OPTIONS] SOURCE\n"
  printf "  upload -h|--help\n"
  printf "\n\033[4m%s\033[0m\n" "Arguments:"
  printf "  SOURCE\n"
  printf "    URL to download from\n"
  printf "    [@required]\n"

  printf "\n\033[4m%s\033[0m\n" "Options:"
  printf "  -f --force\n"
  printf "    Force upload\n"
  printf "  -h --help\n"
  printf "    Print help\n"
}
parse_upload_arguments() {
  while [[ $# -gt 0 ]]; do
    case "${1:-}" in
      -h|--help)
        upload_usage
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
        else
          printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid argument: " "$key" >&2
          exit 1
        fi
        ;;
    esac
  done
}
# Upload a file
upload() {
  local rargs_force
  local rargs_source
  # Parse command arguments
  parse_upload_arguments "$@"

  
  if [[ -z "$rargs_source" ]]; then
    printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Missing required option: " "source" >&2
    upload_usage >&2
    exit 1
  fi
  inspect_args
}

rargs_run() {
  declare -A deps=()
  declare -a rargs_input=()
  normalize_rargs_input "$@"
  parse_arguments "${rargs_input[@]}"
  # Call the right command action
  case "$action" in
    "download")
      download "${rargs_input[@]}"
      exit
      ;;
    "upload")
      upload "${rargs_input[@]}"
      exit
      ;;
    "")
      upload
      exit
      ;;
    
  esac
}

rargs_run "$@"
