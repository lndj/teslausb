#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login
check_config_file

# todo
bucket=${_POST['bucket']} #my-tesla-dashcam
provider=${_POST['provider']} #Alibaba
key_id=${_POST['key_id']} #LTAI5t9eYJaw3P9XWro3wV28
access_key=${_POST['access_key']} #TeRnxOhaSJoz9gCJrZtPcL4PMGaTdZ
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

cat <<- EOF > /root/.config/rclone/rclone.conf
[oss]
type = s3
provider = $provider
access_key_id = $key_id
secret_access_key = $access_key
endpoint = $endpoint
EOF

msg=$(rclone ls oss:"$bucket" | head -n 1)
if grep -e "Failed.*" -a "$msg" &> /dev/null; then
  rm -f /root/.config/rclone/rclone.conf
  mv /root/.config/rclone/rclone.conf.bak /root/.config/rclone/rclone.conf
  response_json_with_msg "$PARAM_ERROR" "rclone config error: $msg"
else
  rm -f /root/.config/rclone/rclone.conf.bak
  response_json_with_msg "$OK" "Set rclone config success"
fi
