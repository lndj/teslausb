#!/bin/bash

# shellcheck disable=SC2034
PARAM_ERROR=101
LOGIN_ERROR=102
OK=0


# Build Res body
res_body() {
  code=$1
  data=$2
  msg=$3

  cat <<EOF
{
  "code":$code,
  "msg":"$msg",
  "data":$data
}
EOF
}
