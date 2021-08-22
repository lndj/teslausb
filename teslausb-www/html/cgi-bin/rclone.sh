#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login
check_config_file

bucket=${_POST['bucket']} # my-tesla-dashcam
provider=${_POST['provider']} # Alibaba
key_id=${_POST['key_id']} #
access_key=${_POST['access_key']} #
endpoint=${_POST['endpoint']} # oss-cn-shanghai.aliyuncs.com

if [[ -z $bucket || -z $provider || -z $key_id || -z $access_key || -z $endpoint ]]; then
  response_json_with_msg "$PARAM_ERROR" "params field error, please check."
  exit 0
fi

set_config_field "ARCHIVE_SYSTEM" "rclone" 0
set_config_field "RCLONE_DRIVE" "oss" 1
set_config_field "RCLONE_PATH" "$bucket" 1
# set_config_field "RCLONE_FLAGS" ""

BAK_CONFIG="/tmp/rclone.conf"
if [[ -f $RCLONE_CONFIG_FILE ]]; then
  cp "$RCLONE_CONFIG_FILE" "$BAK_CONFIG"
fi

sudo mkdir -p /root/.config/rclone
conf=$(cat <<EOF
[oss]
type=s3
provider=$provider
access_key_id=$key_id
secret_access_key=$access_key
endpoint=$endpoint
EOF
)
echo "$conf" | sudo tee "$RCLONE_CONFIG_FILE" > /dev/null

function res_failed() {
  rm -f "$RCLONE_CONFIG_FILE"
  mv "$BAK_CONFIG" "$RCLONE_CONFIG_FILE"
  response_json_with_msg "$PARAM_ERROR" "$1"
}

if ! rclone --config "$RCLONE_CONFIG_FILE" lsd "oss:$bucket" > /dev/null
then
    res_failed "配置错误，请检查"
    exit 1
fi

rm -f "$BAK_CONFIG"
response_json_with_msg "$OK" "Set rclone config success"
