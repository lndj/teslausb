#!/bin/bash -eu

if [[ $EUID -ne 0 ]]
then
  setup_progress "STOP: Run sudo -i."
  exit 1
fi

# install dep
apt-get update
apt-get install git coreutils quilt parted qemu-user-static debootstrap zerofree zip \
dosfstools libarchive-tools libcap2-bin grep rsync xz-utils file git curl bc \
qemu-utils kpartx screen -y

cd /root

git clone https://github.com/marcone/teslausb.git
git clone https://github.com/RPi-Distro/pi-gen.git

# Gen pi-gen config file
cd pi-gen

cat <<- EOF > config
IMG_NAME=teslausb
HOSTNAME=teslausb
STAGE_LIST="stage0 stage1 stage2 stage_teslausb"
EOF

rm -rf stage2/EXPORT_NOOBS
mkdir stage_teslausb
touch stage_teslausb/EXPORT_IMAGE
cp stage2/prerun.sh stage_teslausb/prerun.sh

cd /root && cp -R teslausb/pi-gen-sources/00-teslausb-tweaks pi-gen/stage_teslausb

sed -i -e "s/200 \* 1024 \* 1024/400 \* 1024 \* 1024/g" pi-gen/export-image/prerun.sh

screen -S pi

cd pi-gen && ./build.sh
