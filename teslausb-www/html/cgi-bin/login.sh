#!/bin/bash

# shellcheck disable=SC1091
source www.sh
source util.sh

username=${_POST['username']}
password=${_POST['password']}
if [[ -z $username || -z $password ]]; then
  res=$(res_body "$PARAM_ERROR" "{}" "username or password param error")
  response_json "$res"
  exit 0
fi

# Check username & password
# todo db file path
rows=$(sqlite3 /var/www/teslausb.db -csv "select id,password,nickname,icon,status from user_info where username='$username' limit 1;")
db_password=$(echo "$rows" | awk -F ',' '{print $2}')
if [[ $db_password != "$password" ]]; then
  res=$(res_body "$LOGIN_ERROR" "{}" "password is error")
  response_json "$res"
  exit 0
fi

token=$(gen_auth_token "username=$username&uid=$uid")
uid=$(echo "$rows" | awk -F ',' '{print $1}')
res_data=$(cat <<EOF
  {
    "id": $uid,
    "nickname": "$(echo "$rows" | awk -F ',' '{print $3}' | tr -d '"')",
    "icon": "$(echo "$rows" | awk -F ',' '{print $4}')",
    "status": $(echo "$rows" | awk -F ',' '{print $5}'),
    "token": "$token"
  }
EOF
)
http_cookie "$TOKEN_NAME" "$token" "/" "$TOKEN_EXPIRE_SECONDS"
res=$(res_body "$OK" "$res_data" "ok")
response_json "$res"
