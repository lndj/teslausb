#!/bin/bash

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

check_login
check_config_file

type=${_POST['type']}
if [[ -z $type ]]; then
  response_json_with_msg "$PARAM_ERROR" "You must choose a notification type."
  exit 1
fi
disable_other=${_POST['disable_other']:-false}
disable_all=${_POST['disable_all']:-false}


function disable_other_type_except() {
  if [[ $1 != "bark" ]]; then
    set_config_field "BARK_ENABLED" "false"
  fi
  if [[ $1 != "slack" ]]; then
    set_config_field "SLACK_ENABLED" "false"
  fi
  if [[ $1 != "pushover" ]]; then
    set_config_field "PUSHOVER_ENABLED" "false"
  fi
  if [[ $1 != "gotify" ]]; then
    set_config_field "GOTIFY_ENABLED" "false"
  fi
  if [[ $1 != "ifttt" ]]; then
    set_config_field "IFTTT_ENABLED" "false"
  fi
  if [[ $1 != "webhook" ]]; then
    set_config_field "WEBHOOK_ENABLED" "false"
  fi
}

function check_and_set_bark() {
  token=$1
  if [[ -z $token ]]; then
    response_json_with_msg "$PARAM_ERROR" "You must set bark token."
    exit 1
  fi
  set_config_field "BARK_ENABLED" "true"
  set_config_field "BARK_TOKEN" "$token" 1
}

function check_and_set_slack() {
  url=$1
  if [[ -z $url ]]; then
    response_json_with_msg "$PARAM_ERROR" "You must set slack web hook url."
    exit 1
  fi
  set_config_field "SLACK_ENABLED" "true"
  set_config_field "SLACK_WEBHOOK_URL" "$url" 1
}

function check_and_set_pushover() {
  user_key=$1
  app_key=$2
  if [[ -z $user_key || -z $app_key ]]; then
    response_json_with_msg "$PARAM_ERROR" "You must set push over user key and app key."
    exit 1
  fi
  set_config_field "PUSHOVER_ENABLED" "true"
  set_config_field "PUSHOVER_USER_KEY" "$user_key" 1
  set_config_field "PUSHOVER_APP_KEY" "$app_key" 1
}

function check_and_set_gotify() {
  gotify_domain=$1
  gotify_token=$2
  gotify_priority=${3:-5}
  if [[ -z $gotify_domain || -z $gotify_token ]]; then
    response_json_with_msg "$PARAM_ERROR" "You must set gotify domain and app token."
    exit 1
  fi
  set_config_field "GOTIFY_ENABLED" "true"
  set_config_field "GOTIFY_DOMAIN" "$gotify_domain"
  set_config_field "GOTIFY_APP_TOKEN" "$gotify_token"
  set_config_field "GOTIFY_PRIORITY" "$gotify_priority"
}

function check_and_set_ifttt() {
  ifttt_event_name=$1
  ifttt_key=$2
  if [[ -z $ifttt_event_name || -z $ifttt_key ]]; then
    response_json_with_msg "$PARAM_ERROR" "You must set ifttt event name and key."
    exit 1
  fi
  set_config_field "IFTTT_ENABLED" "true"
  set_config_field "IFTTT_EVENT_NAME" "$ifttt_event_name"
  set_config_field "IFTTT_KEY" "$ifttt_key"
}

function check_and_set_webhook() {
  webhook_url=$1
  if [[ -z $webhook_url ]]; then
    response_json_with_msg "$PARAM_ERROR" "You must set webhook url."
    exit 1
  fi
  set_config_field "WEBHOOK_ENABLED" "true"
  set_config_field "WEBHOOK_URL" "$webhook_url"
}

case "$type" in
  bark)
    bar_token=${_POST['bar_token']}
    check_and_set_bark "$bar_token"
    ;;
  slack)
    slack_webhook_url=${_POST['slack_webhook_url']}
    check_and_set_slack "$slack_webhook_url"
    ;;
  pushover)
    pushover_user_key=${_POST['pushover_user_key']}
    pushover_app_key=${_POST['pushover_app_key']}
    check_and_set_pushover "$pushover_user_key" "$pushover_app_key"
    ;;
  gotify)
    gotify_domain=${_POST['gotify_domain']}
    gotify_token=${_POST['gotify_token']}
    gotify_priority=${_POST['gotify_priority']}
    check_and_set_gotify "$gotify_domain" "$gotify_token" "$gotify_priority"
    ;;
  ifttt)
    ifttt_event_name=${_POST['ifttt_event_name']}
    ifttt_key=${_POST['ifttt_key']}
    check_and_set_ifttt "$ifttt_event_name" "$ifttt_key"
    ;;
  webhook)
    webhook_url=${_POST['webhook_url']}
    check_and_set_webhook "$webhook_url"
    ;;
  (*)
    response_json_with_msg "$PARAM_ERROR" "Notification type error, please choose again."
    exit 1
    ;;
esac

debug_log "$disable_other ----- $disable_all"

if [[ $disable_other == 'true' ]]; then
  disable_other_type_except "$type"
fi

if [[ $disable_all == 'true' ]]; then
  disable_other_type_except "none"
fi

response_json_with_msg "$OK" "Notification config change success"
