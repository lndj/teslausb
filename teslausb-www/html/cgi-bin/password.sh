#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login

pre_pass=${_POST['pre_pass']}
new_pass=${_POST['new_pass']}
if [[ -z $pre_pass || -z $new_pass ]]; then
  response_json_with_msg "$PARAM_ERROR" "pre_pass or new_pass field error, please check."
  exit 1
fi
username=$(get_value_from_token "username")
if [[ -z $username ]]; then
  response_json_with_msg "$PARAM_ERROR" "Get username error, please login again."
  exit 1
fi

rows=$(sqlite3 "$DB_FILE_PATH" -csv "select id,password,nickname,icon,status from user_info where username='$username' limit 1;")
db_password=$(echo "$rows" | awk -F ',' '{print $2}')
if [[ $db_password != "$pre_pass" ]]; then
  res=$(res_body "$LOGIN_ERROR" "{}" "Pre password is error")
  response_json "$res"
  exit 0
fi

sqlite3 "$DB_FILE_PATH" "update user_info set password='$new_pass' where username='$username';"

response_json_with_msg "$OK" "Change password success"
