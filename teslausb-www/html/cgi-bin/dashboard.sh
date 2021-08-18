#!/bin/bash

# Get some dashboard data
# Includes:
#   1. Vedio numbers & size
#   2. Latest sync info
#   3. Sync times in history
#   4. Current system info: wifi / Music / Sync status etc.
#   5. And more ...

SHELL_FOLDER=$(dirname "$(readlink -f "$0")")
source "$SHELL_FOLDER/www.sh"
source "$SHELL_FOLDER/env.sh"
source "$SHELL_FOLDER/util.sh"

hardware=$( tr -d '\000' < /sys/firmware/devicetree/base/model )
os=$(. /etc/os-release && echo "$PRETTY_NAME")

cam_size=''
if [ -f /backingfiles/cam_disk.bin ]
then
  cam_size_raw=$( parted -s /backingfiles/cam_disk.bin print )
  if [ -n "$cam_size_raw" ]
  then
    cam_size=$(grep -e '^Disk /backingfiles/cam_disk.bin*' | awk '{print $3}')
  fi
fi

music_size=''
if [ -f /backingfiles/music_disk.bin ]
then
  music_size_raw=$( parted -s /backingfiles/music_disk.bin print )
  if [ -n "$music_size_raw" ]
  then
    music_size=$(grep -e '^Disk /backingfiles/music_disk.bin*' | awk '{print $3}')
  fi
fi

res_data=$(cat <<EOF
  {
    "hardware":"$hardware",
    "os":"$os",
    "cam_size":"$cam_size",
    "music_size":"$music_size"
  }
EOF
)
res=$(res_body "$OK" "$res_data" "ok")
response_json "$res"
