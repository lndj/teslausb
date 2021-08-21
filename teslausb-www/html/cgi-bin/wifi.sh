#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login
check_config_file

ssid=${_POST['ssid']}
wifi_pass=${_POST['wifi_pass']}
if [[ -z $ssid || -z $wifi_pass ]]; then
  response_json_with_msg "$PARAM_ERROR" "ssid or wifi_pass field error, please check."
  exit 1
fi

set_config_field "SSID" "$ssid" 1 "WiFi"
set_config_field "WIFIPASS" "$wifi_pass" 1

sudo touch /boot/WIFI_CONFIG_CHANGED

response_json_with_msg "$OK" "Wifi config change success"
