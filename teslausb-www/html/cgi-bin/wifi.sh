#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login

ssid=${_POST['ssid']}
wifi_pass=${_POST['wifi_pass']}
if [[ -z $ssid || -z $wifi_pass ]]; then
  response_json_with_msg "$PARAM_ERROR" "ssid or wifi_pass field error, please check."
  exit 1
fi

function change_wifi () {
  if [ -e /root/bin/remountfs_rw ]
  then
    sudo /root/bin/remountfs_rw > /dev/null 2>&1
  fi
  sudo cp /boot/wpa_supplicant.conf.sample /boot/wpa_supplicant.conf
  sudo sed -i -e "sTEMPSSID${ssid}g" /boot/wpa_supplicant.conf
  sudo sed -i -e "sTEMPPASS${wifi_pass}g" /boot/wpa_supplicant.conf
  sudo cp /boot/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
}

change_wifi

# set_config_field "SSID" "$ssid" 1 "WiFi"
# set_config_field "WIFIPASS" "$wifi_pass" 1

# sudo rm -f /boot/WIFI_ENABLED

response_json_with_msg "$OK" "Wifi config change success"
