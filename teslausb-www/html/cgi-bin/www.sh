#!/bin/bash

# bash library, use "source"
# shellcheck shell=bash

# www.sh - the experimental bash web framework
#
# Thanks for http://nerdgeneration.com/www.sh/
#
# Let's be absolutely clear: this is a joke project. DO NOT USE THIS FOR
# ANYTHING, ESPECIALLY ON A PUBLIC FACING SERVER.
#
# This is the main library that exposes various "web framework" like
# functions:
#   - HTTP status
#   - HTTP headers
#   - HTTP response
#   - Pre-filled $_GET and $_POST data
#
# This also supports:
#   - URL encode/decode
#   - Path checks
#   - Sanitisation of HTML, SQL
#   - MySQL database queries

# Auth Token
TOKEN_NAME=${TOKEN_NAME:-X-Token}
TOKEN_PASS=${TOKEN_PASS:-pass_lndj}
TOKEN_EXPIRE_SECONDS=${TOKEN_EXPIRE_SECONDS:-36000}
TOKEN_EXPIRE_KEY=${TOKEN_EXPIRE_KEY:-exp}

# Some notes:
# - The aim is to use native bash as much as possible
# - printf is more secure than echo because you can't tell echo to stop processing parameters

# Make bash intolerant of errors
set -ef -o pipefail

# Read the .env file
declare -A _ENV
# shellcheck disable=SC1091
[[ -f .env ]] && source .env

url_decode() {
  local data="${*//+/ }"
  printf '%b' "${data//%/\\x}"
}

url_encode() {
  # Modified from https://gist.github.com/cdown/1163649
  old_lc_collate="$LC_COLLATE"
  LC_COLLATE="C"

  local length="${#1}"
  for ((pos = 0; pos < length; pos++)); do
    local chr="${1:pos:1}"
    case "$chr" in
    ' ')
      printf '+'
      ;;
    [a-zA-Z0-9.~_-])
      printf "%s" "$chr"
      ;;
    *)
      printf '%%%02X' "'$chr"
      ;;
    esac
  done

  LC_COLLATE="$old_lc_collate"
}

encrypt() {
  value=$1
  pass=$2
  echo "$value" | openssl aes-256-cbc -a -salt -pass pass:"$pass"
}

decrypt() {
  value=$1
  pass=$2
  echo "$value" | openssl aes-256-cbc -d -a -salt -pass pass:"$pass"
}

html() {
  local str="$1"
  str="${str//</&lt;}"
  str="${str//>/&gt;}"
  str="${str//\"/&quot;}"
  printf "%s" "$str"
}

sql() {
  printf "0x"
  printf "%s" "$1" | xxd -p | tr -d '\n'
}

query() {
  mysql -u "${_ENV['DB_USER']}" -p <(echo "${_ENV['DB_PASS']}") --database="${_ENV['DB_DATABASE']}" --silent --raw <<<"$1" |
    tail -n +2
}

http_status_code="200 OK"
http_status() {
  http_status_code="$1"
}

declare -A http_headers
http_header() {
  http_headers["$1"]="$2"
}

declare -A http_cookies
http_cookie() {
  name=$1
  value=$2
  cookie_path=$3
  max_age=$4
  domain=$5
  secure=$6
  http_only=$7
  same_site=$8
  expires=$9

  cookie_item="$name=$value;"
  if [[ -n $cookie_path ]]; then
    cookie_item="$cookie_item Path=$cookie_path;"
  fi
  if [[ -n $max_age ]]; then
    cookie_item="$cookie_item Max-Age=$max_age;"
  fi
  if [[ -n $domain ]]; then
    cookie_item="$cookie_item Domain=$domain;"
  fi
  if [[ -n $expires ]]; then
    cookie_item="$cookie_item Expires=$expires;"
  fi
  if [[ -n $same_site ]]; then
    cookie_item="$cookie_item SameSite=$same_site;"
  fi
  if [[ -n $secure ]]; then
    cookie_item="$cookie_item Secure;"
  fi
  if [[ -n $http_only ]]; then
    cookie_item="$cookie_item HttpOnly;"
  fi
  # Remove the last ;
  cookie_item=${cookie_item%?}
  http_cookies["$name"]="$cookie_item"
}

http_cookie_raw() {
  http_cookies["$1"]="$2"
}

# response 
response() {
  content=$1
  content_type=$2
  # Output headers
  printf "Status: %s\r\n" "$http_status_code"

  if [[ -n $content_type ]]; then
    http_header "Content-Type" "$content_type"
  else
    http_header "Content-Type" "text/html;charset=utf-8"
  fi

  for name in "${!http_headers[@]}"; do
    printf "%s: %s\r\n" "$name" "${http_headers[$name]}"
  done

  for name in "${!http_cookies[@]}"; do
    printf "Set-Cookie: %s\r\n" "${http_cookies[$name]}"
  done

  printf "\r\n%s\n" "$content"
}

response_json() {
  response "$1" "application/json;charset=utf-8"
}

http_error() {
  printf "Status: 500 Internal Server Error\r\n\r\nInternal Server Error"
  exit 1
}

# Parse the query into $_GET
declare -A _GET
if [[ -n $QUERY_STRING ]]; then
  IFS='&;' read -r -a query <<<"$QUERY_STRING"
  for name_value_str in "${query[@]}"; do
    IFS='=' read -r -a name_value <<<"$name_value_str"
    name="$(url_decode "${name_value[0]}")"
    value="$(url_decode "${name_value[1]}")"
    # shellcheck disable=SC2034
    _GET["$name"]="$value"
  done
fi

# Parse the POST into $_POST
CONTENT_LENGTH="${CONTENT_LENGTH:-0}"
_POST_DATA=""
declare -A _POST
if [[ "$CONTENT_LENGTH" -gt 0 ]]; then
  read -n "$CONTENT_LENGTH" -r _POST_DATA
  case "$HTTP_CONTENT_TYPE" in
  "application/x-www-form-urlencoded")
    IFS='&;' read -n "$CONTENT_LENGTH" -r -a query <<<"$_POST_DATA"
    for name_value_str in "${query[@]}"; do
      IFS='=' read -r -a name_value <<<"$name_value_str"
      name="$(url_decode "${name_value[0]}")"
      value="$(url_decode "${name_value[1]}")"
      # shellcheck disable=SC2034
      _POST["$name"]="$value"
    done
    ;;
  *) ;;

  esac

fi

# Parse the Cookie into $_COOKIE
declare -A _COOKIE
if [[ -n $HTTP_COOKIE ]]; then
  IFS='&;' read -r -a cookie <<<"$HTTP_COOKIE"
  for name_value_str in "${cookie[@]}"; do
    IFS='=' read -r -a name_value <<<"$name_value_str"
    name="$(url_decode "${name_value[0]}")"
    # value="$(url_decode "${name_value[1]}")"
    value="${name_value[1]}"
    _COOKIE["$name"]="$value"
  done
fi

# If has token in the cookies, parse it into $_TOKEN
declare -A _TOKEN
token=${_COOKIE["$TOKEN_NAME"]}
token=$(url_decode "$token")
if [[ -n ${token} ]]; then
  set +e
  decrypt_token=$(decrypt "${token}" "${TOKEN_PASS}")
  if [[ -n ${decrypt_token} ]]; then
    set -e
    IFS='&;' read -r -a cookie <<<"${decrypt_token}"
    for name_value_str in "${cookie[@]}"; do
      IFS='=' read -r -a name_value <<<"$name_value_str"
      name="$(url_decode "${name_value[0]}")"
      value="$(url_decode "${name_value[1]}")"
      # shellcheck disable=SC2034
      _TOKEN["$name"]="$value"
    done
  fi
fi

# Check Auth token is valid
check_token() {
  exp=${_TOKEN["$TOKEN_EXPIRE_KEY"]}
  if [[ -z $exp ]]; then
    echo false
  else
    current_seconds=$(date +%s)
    if [[ $exp -le $current_seconds ]]; then
      echo false
    else
      echo true
    fi
  fi
}

gen_auth_token() {
  exp_seconds=${2:-$TOKEN_EXPIRE_SECONDS}
  cur=$(date +%s)
  exp=$((exp_seconds + cur))
  payload="$1&$TOKEN_EXPIRE_KEY=$exp"
  t=$(encrypt "$payload" "$TOKEN_PASS")
  url_encode "$t"
}

# Set auth token to the cookies
set_auth_token() {
  payload=$1
  exp_seconds=${2:-$TOKEN_EXPIRE_SECONDS}
  t=$(gen_auth_token "$payload" "$exp_seconds")
  http_cookie "$TOKEN_NAME" "$t" "/" "$exp_seconds"
}

# Passing associative arrays is poorly implemented and doesn't allow recursion,
# so we'll use a global instead
# shellcheck disable=SC2034
declare -A tmpl
