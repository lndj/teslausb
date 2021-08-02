#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
# shellcheck source=/dev/null
source "$SHELL_FOLDER/www.sh"
# shellcheck source=/dev/null
source "$SHELL_FOLDER/env.sh"
# shellcheck source=/dev/null
source "$SHELL_FOLDER/util.sh"

check_login
check_config_file

# Test change config file
ssid=${_POST['ssid']}
wifi_pass=${_POST['wifi_pass']}
if [[ -z $ssid || -z $wifi_pass ]]; then
  response_json_with_msg "$PARAM_ERROR" "ssid or wifi_pass field error, please check."
  exit 1
fi

if grep -e '^export SSID=.*' "$CONFIG_FILE" &> /dev/null; then
  debug_log "Find the ssid config, replace it with new content"
  sed -i "s/^export SSID=.*/export SSID='$ssid'/g" "$CONFIG_FILE"
else
  ssid_conf="export SSID='$ssid'"
  debug_log "No ssid config find, write new config to the file: [$ssid_conf]"
  echo "# ========== WiFi ===========" >>  "$CONFIG_FILE"
  echo "$ssid_conf" >>  "$CONFIG_FILE"
fi
# WiFi password
if grep -e '^export WIFIPASS=.*' "$CONFIG_FILE" &> /dev/null; then
  debug_log "Find the config, replace it with new content"
  sed -i "s/^export WIFIPASS=.*/export WIFIPASS='$wifi_pass'/g" "$CONFIG_FILE"
else
  pass_conf="export WIFIPASS='$wifi_pass'"
  debug_log "No WIFIPASS config find, write new config to the file: [$pass_conf]"
  echo "$pass_conf" >>  "$CONFIG_FILE"
fi

# todo: reboot ? or use union btn
# todo enable_wifi rc.local

response_json_with_msg "$OK" "Wifi config change success"
