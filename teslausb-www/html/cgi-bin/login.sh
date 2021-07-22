#!/bin/bash

# shellcheck disable=SC1091
source www.sh
source util.sh

username=${_POST['username']}
password=${_POST['password']}
if [[ -z $username || -z $password ]]; then
  res=$(res_body "$PARAM_ERROR" "{}", "username or password param error")
  response_json "$res"
  exit 0
fi

# Check username & password
# TODO

set_auth_token "username=$username"
res=$(res_body "$OK" "{}", "ok")
response_json "$res"
