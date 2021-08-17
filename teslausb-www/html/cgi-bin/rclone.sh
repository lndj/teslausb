#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login
check_config_file

bucket=${_POST['bucket']} #my-tesla-dashcam
provider=${_POST['provider']} #Alibaba
key_id=${_POST['key_id']} #
access_key=${_POST['access_key']} #
endpoint=${_POST['endpoint']} #oss-cn-shanghai.aliyuncs.com

if [[ -z $bucket || -z $provider || -z $key_id || -z $access_key || -z $endpoint ]]; then
  response_json_with_msg "$PARAM_ERROR" "params field error, please check."
  exit 0
fi

set_config_field "ARCHIVE_SYSTEM" "rclone" 0
set_config_field "RCLONE_DRIVE" "oss" 1
set_config_field "RCLONE_PATH" "$bucket" 1
# set_config_field "RCLONE_FLAGS" ""

if [[ -f /root/.config/rclone/rclone.conf ]]; then
  cp /root/.config/rclone/rclone.conf /root/.config/rclone/rclone.conf.bak
fi

mkdir -p /root/.config/rclone
cat <<- EOF > /root/.config/rclone/rclone.conf
[oss]
type=s3
provider=$provider
access_key_id=$key_id
secret_access_key=$access_key
endpoint=$endpoint
EOF

function res_failed() {
  rm -f /root/.config/rclone/rclone.conf
  mv /root/.config/rclone/rclone.conf.bak /root/.config/rclone/rclone.conf
  response_json_with_msg "$PARAM_ERROR" "$1"
}

echo 'Teslausb config test' > /tmp/oss-test.log
if rclone sync /tmp/oss-test.log oss:"$bucket" &> /dev/null; then
  rm -f /root/.config/rclone/rclone.conf.bak
  response_json_with_msg "$OK" "Set rclone config success"
else
  res_failed "配置错误，请检查"
fi
