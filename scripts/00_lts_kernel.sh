#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

swupd bundle-add kernel-lts || true
mount /dev/sda1 /boot
clr-boot-manager update
LTS_CONFIG=$(basename $(find /boot/loader/entries -name "Clear-linux-lts*" -print -quit))
echo "default ${LTS_CONFIG%.conf}" > /boot/loader/loader.conf
umount /boot

reboot