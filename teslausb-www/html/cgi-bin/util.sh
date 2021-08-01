#!/bin/bash

# shellcheck disable=SC2034
PARAM_ERROR=101
LOGIN_ERROR=102
SYSTEM_ERROR=103
OK=0


# Build Res body
res_body() {
  code=$1
  data=$2
  msg=$3

  cat <<EOF
{
  "code":$code,
  "msg":"$msg",
  "data":$data
}
EOF
}

check_config_file() {
  if [[ ! -e $CONFIG_FILE ]]; then
    response_json_with_msg "$SYSTEM_ERROR" "Something error, config file is not exists."
    exit 1
  fi
}

function debug_log() {
  t=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[DEBUG] $t $1" >> /root/debug.log
}
