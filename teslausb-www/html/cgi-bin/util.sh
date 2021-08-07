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

function check_config_file() {
  if [[ ! -e $CONFIG_FILE ]]; then
    response_json_with_msg "$SYSTEM_ERROR" "Something error, config file is not exists."
    exit 1
  fi
}

function debug_log() {
  t=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[DEBUG] $t $1" >> /root/debug.log
}

function set_config_field() {
  if [[ -z $CONFIG_FILE ]]; then
    CONFIG_FILE="$5"
  fi
  key=$1
  value=$2
  value_quote=${3:-0}
  new_conf_doc_tip=$4

  if grep -e "^export $key=.*" "$CONFIG_FILE" &> /dev/null; then
    debug_log "Find the config, replace it with new content, name=$key,value=$value,value_quote=$value_quote"
    if [[ $value_quote == 1 ]]; then
      sed -i "s#^export $key=.*#export $key='$value'#g" "$CONFIG_FILE"
    else
      sed -i "s#^export $key=.*#export $key=$value#g" "$CONFIG_FILE"
    fi
  else
    if [[ $value_quote == 1 ]]; then
      conf="export $key='$value'"
    else
      conf="export $key=$value"
    fi
    debug_log "No $key config find, write new config to the file: [$conf]"
    if [[ -n $new_conf_doc_tip ]]; then
        echo "" >>  "$CONFIG_FILE"
        echo "# ========== $new_conf_doc_tip ===========" >>  "$CONFIG_FILE"
    fi
    echo "$conf" >>  "$CONFIG_FILE"
  fi
}
