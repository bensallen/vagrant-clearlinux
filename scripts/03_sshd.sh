#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

sed -i '/PermitRootLogin yes/d' /etc/ssh/sshd_config

echo 'UseDNS no' >> /etc/ssh/sshd_config
echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
