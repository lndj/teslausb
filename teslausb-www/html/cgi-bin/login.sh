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
rows=$(sqlite3 /var/www/teslausb.db -json "select * from user_info where username='$username' limit 1;")
db_password=$(echo "$rows" | jq -r '.[0] | .password')
if [[ $db_password != "$password" ]]; then
  res=$(res_body "$LOGIN_ERROR" "{}" "password is error")
  response_json "$res"
  exit 0
fi

token=$(gen_auth_token "username=$username&uid=$uid")
uid=$(echo "$rows" | jq -r '.[0] | .id')
res_data=$(cat <<EOF
  {
    "id": $uid,
    "nickname": "$(echo "$rows" | jq -r '.[0] | .nickname')",
    "icon": "$(echo "$rows" | jq -r '.[0] | .icon')",
    "status": $(echo "$rows" | jq -r '.[0] | .status'),
    "token": "$token"
  }
EOF
)
http_cookie "$TOKEN_NAME" "$token" "/" "$TOKEN_EXPIRE_SECONDS"
res=$(res_body "$OK" "$res_data" "ok")
response_json "$res"
