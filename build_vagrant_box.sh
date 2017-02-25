#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

# Helper functional for sha512 checking on Linux and macOS
SHA512SUM() {
  if hash shasum 2>/dev/null; then
    shasum -a 512 "$@"
  else
    sha512sum "$@"
  fi
}

CHECKDEPS() {
  hash curl 2>/dev/null
  hash packer 2>/dev/null
  hash vagrant 2>/dev/null
  hash VBoxManage 2>/dev/null
  hash shasum 2>/dev/null || hash sha512sum 2>/dev/null
}

VERSION=0.0.2
DESCRIPTION="Build base ClearLinux x86_64"
NAME="clear-linux-base"

CHECKDEPS

LATEST=$(curl https://download.clearlinux.org/current/latest)
LIVE="clear-${LATEST}-live.img.xz"
IMG_SHA512SUM=$(curl "https://download.clearlinux.org/current/${LIVE}-SHA512SUMS")

if [ ! -e "${LIVE}" ]; then
  curl -o "${LIVE}" "https://download.clearlinux.org/current/${LIVE}"
fi

SHA512SUM -c <<< "${IMG_SHA512SUM}"

if [ ! -e "${LIVE%.xz}" ]; then
  xz --decompress --keep "${LIVE}"
fi

if [ ! -e "${NAME}-${LATEST}/${NAME}-${LATEST}.vbox" ]; then
  VBoxManage createvm --name "${NAME}-${LATEST}" --ostype Linux26_64 --basefolder "${PWD}" --register
fi

VBoxManage modifyvm "${NAME}-${LATEST}" --memory 1024 --firmware efi64 --boot1 dvd --boot2 disk --boot3 net --pae on --audio none --usb on --usbxhci on --natdnshostresolver1 off

if ! grep -q "IDE Controller" "${NAME}-${LATEST}/${NAME}-${LATEST}.vbox"; then
  VBoxManage storagectl "${NAME}-${LATEST}" --name "IDE Controller" --add ide
fi

if [ ! -e "${NAME}-${LATEST}/${LIVE%.img.xz}.vdi" ]; then
  VBoxManage convertfromraw "${LIVE%.xz}" "${NAME}-${LATEST}/${LIVE%.img.xz}.vdi" --format VDI
  rm -f "${LIVE%.xz}"
fi

VBoxManage storageattach "${NAME}-${LATEST}" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "${NAME}-${LATEST}/${LIVE%.img.xz}.vdi"

rm -f "${NAME}.ovf" "${NAME}-disk1.vmdk"

VBoxManage export "${NAME}-${LATEST}" --output "${NAME}.ovf" --ovf20

VBoxManage unregistervm "${NAME}-${LATEST}" --delete

packer build -var "name=${NAME}" -var "vm_description=${DESCRIPTION}" -var "vm_version=${VERSION}" packer_conf.json

rm -f "${NAME}.ovf" "${NAME}-disk1.vmdk"

vagrant box add --force --name "${NAME}" "${NAME}.box"