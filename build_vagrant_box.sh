#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

set -o xtrace

VERSION=0.0.1
DESCRIPTION="Build base ClearLinux x86_64"

LATEST=$(curl https://download.clearlinux.org/current/latest)
LIVE="clear-${LATEST}-live.img.xz"

if [ ! -e "${LIVE}" ]; then
  curl -o "${LIVE}" "https://download.clearlinux.org/current/${LIVE}"
fi

if [ ! -e "${LIVE%.xz}" ]; then
  xz --keep --decompress "${LIVE}"
fi

if [ ! -e "clearlinux-base-${LATEST}/clearlinux-base-${LATEST}.vbox" ]; then
  VBoxManage createvm --name "clearlinux-base-${LATEST}" --ostype Linux26_64 --basefolder "${PWD}" --register
fi

VBoxManage modifyvm "clearlinux-base-${LATEST}" --memory 1024 --firmware efi64 --boot1 dvd --boot2 disk --boot3 net --pae on --audio none --usb on --usbxhci on --natdnshostresolver1 off

if ! grep -q "IDE Controller" clearlinux-base-${LATEST}/clearlinux-base-${LATEST}.vbox; then
  VBoxManage storagectl "clearlinux-base-${LATEST}" --name "IDE Controller" --add ide
fi

if [ ! -e "clearlinux-base-${LATEST}/${LIVE%.img.xz}.vdi" ]; then
  VBoxManage convertfromraw "${LIVE%.xz}" "clearlinux-base-${LATEST}/${LIVE%.img.xz}.vdi" --format VDI
fi

VBoxManage storageattach "clearlinux-base-${LATEST}" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "clearlinux-base-${LATEST}/${LIVE%.img.xz}.vdi"

rm -f clearlinux-base.ovf clearlinux-base-disk1.vmdk

VBoxManage export "clearlinux-base-${LATEST}" --output "clearlinux-base.ovf" --ovf20

VBoxManage unregistervm "clearlinux-base-${LATEST}" --delete

packer build -var "vm_description=${DESCRIPTION}" -var "vm_version=${VERSION}" packer_conf.json

vagrant box add --force --name "clear-linux-base" clear-linux-base.box