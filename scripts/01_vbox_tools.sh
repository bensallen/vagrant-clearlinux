#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

swupd bundle-add sysadmin-basic || true
install-vbox-lga