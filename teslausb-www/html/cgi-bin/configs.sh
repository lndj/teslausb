#!/bin/bash

# Load current config for UI

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login
check_config_file

type=${_GET['type']}

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

# Notification
if [[ $type == 'notification' ]]; then
  # Get all enabled notify types
  declare -A notificationTypeMap
  notificationTypeMap['bark']='BARK_ENABLED'
  notificationTypeMap['slack']='SLACK_ENABLED'
  notificationTypeMap['pushover']='PUSHOVER_ENABLED'
  notificationTypeMap['gotify']='GOTIFY_ENABLED'
  notificationTypeMap['ifttt']='IFTTT_ENABLED'
  notificationTypeMap['webhook']='WEBHOOK_ENABLED'
  notification_types=''
  for key in "${!notificationTypeMap[@]}"; do
    v=$(get_config_field "${notificationTypeMap[$key]}")
    if [[ $v == 'true' ]]; then
      if [[ -n $notification_types ]]; then
        notification_types="$notification_types,$key"
      else
        notification_types="$key"
      fi
    fi
  done

  bark_token=$(get_config_field "BARK_TOKEN")
  slack_webhook_url=$(get_config_field "SLACK_WEBHOOK_URL")
  pushover_user_key=$(get_config_field "PUSHOVER_USER_KEY")
  pushover_app_key=$(get_config_field "PUSHOVER_APP_KEY")
  gotify_domain=$(get_config_field "GOTIFY_DOMAIN")
  gotify_token=$(get_config_field "GOTIFY_APP_TOKEN")
  gotify_priority=$(get_config_field "GOTIFY_PRIORITY")
  ifttt_event_name=$(get_config_field "IFTTT_EVENT_NAME")
  ifttt_key=$(get_config_field "IFTTT_KEY")
  webhook_url=$(get_config_field "WEBHOOK_URL")

  res_data=$(cat <<EOF
  {
    "notification_types":"$notification_types",
    "bark_token":"$bark_token",
    "slack_webhook_url":"$slack_webhook_url",
    "pushover_user_key":"$pushover_user_key",
    "pushover_app_key":"$pushover_app_key",
    "gotify_domain":"$gotify_domain",
    "gotify_token":"$gotify_token",
    "gotify_priority":"$gotify_priority",
    "ifttt_event_name":"$ifttt_event_name",
    "ifttt_key":"$ifttt_key",
    "webhook_url":"$webhook_url"
  }
EOF
)
  res=$(res_body "$OK" "$res_data" "ok")
  response_json "$res"
  exit 0
fi

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
