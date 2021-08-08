#!/bin/bash -eu

setup_progress "configuring rclone"

#create tmp directory and move to it with macOS compatibility fallback
tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'rclone-install.XXXXXXXXXX')
cd "$tmp_dir"

# Make sure we don't create a root owned .config/rclone directory #2127
export XDG_CONFIG_HOME=config

#check installed version of rclone to determine if update is necessary
version=$(rclone --version 2>>errors | head -n 1)
# current_version=$(curl -fsS https://downloads.rclone.org/version.txt)
# if [ "$version" = "$current_version" ]; then
if [ -n "$version" ]; then
    setup_progress "The version of rclone ${version} is already installed."
else
  download_link="https://downloads.rclone.org/rclone-current-linux-arm.zip"
  rclone_zip="rclone-current-linux-arm.zip"
  curlwrapper -o "$rclone_zip" "$download_link"
  unzip_dir="tmp_unzip_dir_for_rclone"
  unzip -a "$rclone_zip" -d "$unzip_dir"
  cd $unzip_dir/*

  cp rclone /usr/bin/rclone.new
  chmod 755 /usr/bin/rclone.new
  chown root:root /usr/bin/rclone.new
  mv /usr/bin/rclone.new /usr/bin/rclone
  #manual
  if ! [ -x "$(command -v mandb)" ]; then
      echo 'mandb not found. The rclone man docs will not be installed.'
  else 
      mkdir -p /usr/local/share/man/man1
      cp rclone.1 /usr/local/share/man/man1/
      mandb
  fi
  version=$(rclone --version 2>>errors | head -n 1)
  setup_progress "rclone ${version} has successfully installed."
fi

setup_progress "done install rclone"
