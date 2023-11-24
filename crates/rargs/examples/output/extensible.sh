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
      --)
        shift
        other_args+=("$@")
        break
        ;;
      -?*)
        other_args+=("$1")
        shift
        ;;
      *)
        other_args+=("$1")
        shift
        ;;
    esac
  done
}

root() {
  # Parse command arguments
  parse_root "$@"

  echo "Here you would call the following command"
  echo "  external-${other_args[0]}" "${other_args[@]:1}"
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
  printf "Sample application that can be externally extended\n"
  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  extensible [OPTIONS] [COMMAND] [COMMAND_OPTIONS] [...EXTERNAL_COMMAND]\n"
  printf "  extensible -h|--help\n"
  printf "  extensible -v|--version\n"
  printf "\n\033[4m%s\033[0m\n" "Examples:"
  printf "  extensible example [OPTIONS] [ARGS]\n"
  printf "    Run a command found in path prefixed with "extensible-"\n"
  printf "\n\033[4m%s\033[0m\n" "Arguments:"
  printf "  EXTERNAL_COMMAND\n"
  printf "    External command to run\n"
  printf "\n\033[4m%s\033[0m\n" "Commands:"
  cat <<EOF
  download .... Download a file
  upload ...... Upload a file
EOF

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
      action="root"
      ;;
    *)
      action="root"
      ;;
  esac
}
download_usage() {
  printf "Download a file\n"
  printf "\n\033[4m%s\033[0m %s\n" "Alias:" "d"

  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  download [OPTIONS] SOURCE ...[]\n"
  printf "  download -h|--help\n"
  printf "\n\033[4m%s\033[0m\n" "Arguments:"
  printf "  SOURCE\n"
  printf "    File to download\n"
  printf "    [@required]\n"
  printf "  EXTERNAL_COMMAND\n"
  printf "    External command to run\n"

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
      --)
        shift
        other_args+=("$@")
        break
        ;;
      -?*)
        other_args+=("$1")
        shift
        ;;
      *)
        if [[ -z "$rargs_source" ]]; then
          rargs_source=$key
          shift
        else
          other_args+=("$1")
          shift
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
  echo "Download"
  inspect_args
}
upload_usage() {
  printf "Upload a file\n"
  printf "\n\033[4m%s\033[0m %s\n" "Alias:" "u"

  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  upload [OPTIONS] SOURCE ...[]\n"
  printf "  upload -h|--help\n"
  printf "\n\033[4m%s\033[0m\n" "Arguments:"
  printf "  SOURCE\n"
  printf "    File to upload\n"
  printf "    [@required]\n"
  printf "  EXTERNAL_COMMAND\n"
  printf "    External command to run\n"

  printf "\n\033[4m%s\033[0m\n" "Options:"
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
      --)
        shift
        other_args+=("$@")
        break
        ;;
      -?*)
        other_args+=("$1")
        shift
        ;;
      *)
        if [[ -z "$rargs_source" ]]; then
          rargs_source=$key
          shift
        else
          other_args+=("$1")
          shift
        fi
        ;;
    esac
  done
}
# Upload a file
upload() {
  local rargs_source
  # Parse command arguments
  parse_upload_arguments "$@"

  
  if [[ -z "$rargs_source" ]]; then
    printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Missing required option: " "source" >&2
    upload_usage >&2
    exit 1
  fi
  echo "Upload"
  inspect_args
}

rargs_run() {
  declare -A deps=()
  declare -a other_args=()
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
