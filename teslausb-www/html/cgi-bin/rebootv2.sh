#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/util.sh"

response_json_with_msg "$OK" "OK"

action=${_GET['action']}
if [[ $action == '1' ]]; then
  sudo reboot &> /dev/null
fi
