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
  prefix="rargs_"
  args="$(set | grep ^$prefix || true)"
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
  echo "0.1.0"
}
usage() {
  printf "NovelAI CLI to call the NovelAI API\n"
  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  novelai [OPTIONS] [COMMAND] [COMMAND_OPTIONS]\n"
  printf "  novelai -h|--help\n"
  printf "  novelai -v|--version\n"
  printf "\n\033[4m%s\033[0m\n" "Commands:"
  cat <<EOF
  generate-stream .... Generate a completion stream
EOF

  printf "\n\033[4m%s\033[0m\n" "Options:"
  printf "  --novelai-api-key [<NOVELAI-API-KEY>]\n"
  printf "    NovelAI API Key\n"
  printf "  --novelai-endpoint [<NOVELAI-ENDPOINT>]\n"
  printf "    NovelAI API Endpoint\n"
  printf "    [@default https://api.novelai.net/ai/generate-stream]\n"
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
    generate-stream)
      action="generate-stream"
      input=("${input[@]:1}")
      ;;
    -h|--help)
      usage
      exit
      ;;
    "")
      ;;
    *)
      printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid command: " "$action" >&2
      exit 1
      ;;
  esac
}
generate-stream_usage() {
  printf "Generate a completion stream\n"

  printf "\n\033[4m%s\033[0m\n" "Usage:"
  printf "  generate-stream [OPTIONS] [INPUT]\n"
  printf "  generate-stream -h|--help\n"
  printf "\n\033[4m%s\033[0m\n" "Arguments:"
  printf "  INPUT\n"
  printf "    Input for the text generation model (reads from stdin if empty)\n"
  printf "    [@default -]\n"

  printf "\n\033[4m%s\033[0m\n" "Options:"
  printf "  -M --max-length [<MAX-LENGTH>]\n"
  printf "    Maximum length of the generated text. [@min 1, @max 2048]\n"
  printf "    [@default 40]\n"
  printf "  -m --min-length [<MIN-LENGTH>]\n"
  printf "    Minimum length of the generated text. [@min 1, @max 2048]\n"
  printf "    [@default 1]\n"
  printf "  -m --model [<MODEL>]\n"
  printf "    Used text generation model.\n"
  printf "    [@default kayra-v1, @choices kayra-v1, clio-v1, purple, green, red, blue, sigurd-2.9b-v1, cassandra, infillmodel, hypebot, krake-v2, genji-jp-6b-v2, genji-python-6b, euterpe-v2, 6B-v4, 2.7B]\n"
  printf "  --novelai-api-key [<NOVELAI-API-KEY>]\n"
  printf "    NovelAI API Key\n"
  printf "  --novelai-endpoint [<NOVELAI-ENDPOINT>]\n"
  printf "    NovelAI API Endpoint\n"
  printf "    [@default https://api.novelai.net/ai/generate-stream]\n"
  printf "  -t --temperature [<TEMPERATURE>]\n"
  printf "    Temperature for the generation. [@min 0.1, @max 100]\n"
  printf "    [@default 3]\n"
  printf "  -u --use-string [<USE-STRING>]\n"
  printf "    If false, input and output strings should be Base64-encoded uint16 numbers representing tokens.\n"
  printf "    [@default true, @choices true, false]\n"
  printf "  -h --help\n"
  printf "    Print help\n"
}
parse_generate-stream_arguments() {
  while [[ $# -gt 0 ]]; do
    case "${1:-}" in
      -h|--help)
        generate-stream_usage
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
      -M | --max-length)
        rargs_max_length="$2"
        shift 2
        ;;
      -m | --min-length)
        rargs_min_length="$2"
        shift 2
        ;;
      -m | --model)
        rargs_model="$2"
        shift 2
        ;;
      --novelai-api-key)
        rargs_novelai_api_key="$2"
        shift 2
        ;;
      --novelai-endpoint)
        rargs_novelai_endpoint="$2"
        shift 2
        ;;
      -t | --temperature)
        rargs_temperature="$2"
        shift 2
        ;;
      -u | --use-string)
        rargs_use_string="$2"
        shift 2
        ;;
      -?*)
        printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option: " "$key" >&2
        exit 1
        ;;
      *)
        if [[ -z "$rargs_input" ]]; then
          rargs_input=$key
          shift
        else
          printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid argument: " "$key" >&2
          exit 1
        fi
        ;;
    esac
  done
}
# Generate a completion stream
generate-stream() {
  # Parse environment variables
  
  if [[ -n "$rargs_novelai_api_key" ]]; then
    rargs_novelai_api_key="${NOVELAI_API_KEY:-}"
  fi
  if [[ -n "$rargs_novelai_endpoint" ]]; then
    rargs_novelai_endpoint="${NOVELAI_ENDPOINT:-}"
  fi

  # Parse command arguments
  parse_generate-stream_arguments "$@"

  
    
  if [[ -z "$rargs_max_length" ]]; then
    rargs_max_length="40"
  fi
    
    
  if [[ -z "$rargs_min_length" ]]; then
    rargs_min_length="1"
  fi
    
    
  if [[ -z "$rargs_model" ]]; then
    rargs_model="kayra-v1"
  fi
    
    
  if [[ -z "$rargs_novelai_endpoint" ]]; then
    rargs_novelai_endpoint="https://api.novelai.net/ai/generate-stream"
  fi
    
    
  if [[ -z "$rargs_temperature" ]]; then
    rargs_temperature="3"
  fi
    
    
  if [[ -z "$rargs_use_string" ]]; then
    rargs_use_string="true"
  fi
    
    
  if [[ -z "$rargs_input" ]]; then
    rargs_input="-"
  fi
    
  
  if [[ -n "$rargs_model" ]]; then
    if [[ ! "(kayra-v1 clio-v1 purple green red blue sigurd-2.9b-v1 cassandra infillmodel hypebot krake-v2 genji-jp-6b-v2 genji-python-6b euterpe-v2 6B-v4 2.7B)" =~ $rargs_model ]]; then
      printf "\e[31m%s\e[33m%s\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option for " "model" ": " "$rargs_model" >&2
      generate-stream_usage >&2
      exit 1
    fi
  fi
  if [[ -n "$rargs_use_string" ]]; then
    if [[ ! "(true false)" =~ $rargs_use_string ]]; then
      printf "\e[31m%s\e[33m%s\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Invalid option for " "use-string" ": " "$rargs_use_string" >&2
      generate-stream_usage >&2
      exit 1
    fi
  fi
  local input=()
  if [[ "${args["input"]}" == "-" ]]; then
    while read -r line; do
      input+=("$line")
    done
  else
    input=("${args["input"]}")
  fi
  curl -X 'POST' \
    "${args["novelai-endpoint"]}" \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
    "input": '"$(jq -R @json <<<"${input[@]}")"',
    "model": "'"${args["model"]}"'",
    "parameters": {
      "use_string": '"${args["use-string"]}"',
      "temperature": '"${args["temperature"]}"',
      "min_length": '"${args["min-length"]}"',
      "max_length": '"${args["max-length"]}"',
      "typical_p": 0.969,
      "tail_free_sampling": 0.941,
      "repetition_penalty": 3,
      "repetition_penalty_range": 4000,
      "repetition_penalty_frequency": 0,
      "repetition_penalty_presence": 0,
      "cfg_scale": 1.48,
      "cfg_uc":"",
      "phrase_rep_pen":"medium",
      "mirostat_tau":4.95,
      "mirostat_lr":0.22,
      "bad_words_ids":[
        [3],[49356],[1431],[31715],[34387],[20765],[30702],[10691],[49333],[1266],[19438],[43145],[26523],[41471],[2936],[85,85],[49332],[7286],[1115]
      ],
      "repetition_penalty_whitelist": [ 49256, 49264, 49231, 49230, 49287, 85, 49255, 49399, 49262, 336, 333, 432, 363, 468, 492, 745, 401, 426, 623, 794, 1096, 2919, 2072, 7379, 1259, 2110, 620, 526, 487, 16562, 603, 805, 761, 2681, 942, 8917, 653, 3513, 506, 5301, 562, 5010, 614, 10942, 539, 2976, 462, 5189, 567, 2032, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 588, 803, 1040, 49209, 4, 5, 6, 7, 8, 9, 10, 11, 12 ],
      "repetition_penalty": 1,
      "repetition_penalty_presence": 0,
      "repetition_penalty_frequency": 0,
      "repetition_penalty_range": 4000,
      "generate_until_sentence":true,
      "use_cache":false,
      "return_full_text":false,
      "prefix":"special_proseaugmenter",
      "logit_bias_exp":[
        {
          "sequence":[23],
          "bias":-0.08,
          "ensure_sequence_finish":false,
          "generate_once":false
        },{
          "sequence":[21],
          "bias":-0.08,
          "ensure_sequence_finish":false,
          "generate_once":false
        }
      ],
      "num_logprobs":10,
      "order":[8,6,5,0,3]
    }
  }' -N -s \
  | while read -r line; do
    if [[ $line == data:* ]]; then
      if [[ "$line" != "data: [DONE]" ]]; then
        printf "%s" "$(yq <<<"$line" | cut -c6- | jq '.token' -r | grep -v "^null$")"
      else
        echo
      fi
    fi
  done
}

run() {
  declare -A deps=()
  declare -a input=()
  normalize_input "$@"
  parse_arguments "${input[@]}"
  # Check global environment variables
  
  if [[ -n "$rargs_novelai_api_key" ]]; then
    rargs_novelai_api_key="${NOVELAI_API_KEY:-}"
  fi
  if [[ -n "$rargs_novelai_endpoint" ]]; then
    rargs_novelai_endpoint="${NOVELAI_ENDPOINT:-}"
  fi

  # Call the right command action
  case "$action" in
    "generate-stream")
      generate-stream "${input[@]}"
      exit
      ;;
    "")
      printf "\e[31m%s\e[33m%s\e[31m\e[0m\n\n" "Missing command. Select one of " "generate-stream" >&2
      usage >&2
      exit 1
      ;;
    
  esac
}

run "$@"
