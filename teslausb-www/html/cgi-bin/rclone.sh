#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login

provider=Alibaba
key_id=LTAI5t9eYJaw3P9XWro3wV28
access_key=TeRnxOhaSJoz9gCJrZtPcL4PMGaTdZ
endpoint=oss-cn-shanghai.aliyuncs.com


cat <<- EOF > /root/.config/rclone/rclone.conf
[oss]
type = s3
provider = $provider
access_key_id = $key_id
secret_access_key = $access_key
endpoint = $endpoint
EOF

response_json_with_msg "$OK" "Set rclone config success"
