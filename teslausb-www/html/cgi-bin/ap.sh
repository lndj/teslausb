#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login
check_config_file

ap_ssid=${_POST['ap_ssid']}
ap_pass=${_POST['ap_pass']}
if [[ -z $ap_ssid || -z $ap_pass ]]; then
  response_json_with_msg "$PARAM_ERROR" "ap_ssid or ap_pass field error, please check."
  exit 1
fi

set_config_field "AP_SSID" "$ap_ssid" 1 "AP-Config"
set_config_field "AP_PASS" "$ap_pass" 1

host_name=${_POST['host_name']}
if [[ -n $host_name ]]; then
  set_config_field "TESLAUSB_HOSTNAME" "$host_name"
fi

response_json_with_msg "$OK" "Ap config change success"
