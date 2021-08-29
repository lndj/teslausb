#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login

type=${_GET['type']}

# Get current version
if [[ $type == '1' ]]; then
  cur_version=$(sudo cat /mutable/version)
  res_data=$(cat <<EOF
  {
    "cur_version":"$cur_version"
  }
EOF
)
  res=$(res_body "$OK" "$res_data" "ok")
  response_json "$res"
  exit 0
fi

# Get new version
if [[ $type == '2' ]]; then
  rm -f /tmp/current-version.sh
  get_script /tmp current-version.sh setup/pi > /dev/null
  new_version=$(/tmp/current-version.sh)
  res_data=$(cat <<EOF
  {
    "new_version":"$new_version"
  }
EOF
)
  res=$(res_body "$OK" "$res_data" "ok")
  response_json "$res"
  exit 0
fi

# Upgrade
if [[ $type == '3' ]]; then
  sudo /root/bin/setup-teslausb upgrade
  response_json_with_msg "$OK" "Upgrade success"
  exit 0
fi

response_json_with_msg "$OK" "Type error"
