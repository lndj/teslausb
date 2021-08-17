#!/bin/bash

# Load current config for UI

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login
check_config_file

# WiFi
ssid=$(get_config_field "SSID")
wifi_pass=$(get_config_field "WIFIPASS")

# Rclone
function get_rclone_config() {
  < /root/.config/rclone/rclone.conf grep -e "$1=*" | awk -F '=' '{print $2}'
}
rclone_conf_file="/root/.config/rclone/rclone.conf"
if [[ -e $rclone_conf_file ]]; then
  provider=$(get_rclone_config "provider")
  bucket=$(get_config_field "RCLONE_PATH")
  key_id=$(get_rclone_config "access_key_id")
  access_key=$(get_rclone_config "secret_access_key")
  endpoint=$(get_rclone_config "endpoint")
fi

# Ap

# Notification ; todo strategy

res_data=$(cat <<EOF
  {
    "ssid":"$ssid",
    "wifi_pass":"$wifi_pass",
    "provider":"$provider",
    "bucket":"$bucket",
    "key_id":"$key_id",
    "access_key":"$access_key",
    "endpoint":"$endpoint"
  }
EOF
)
res=$(res_body "$OK" "$res_data" "ok")
response_json "$res"
