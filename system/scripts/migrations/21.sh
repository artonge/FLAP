#!/bin/bash

set -euo pipefail

# Version v1.14.2

echo "* [21] Install fail2ban."
apt install -y fail2ban

echo "* [21] Limit log retention time to 1 year."
sed -i 's/#\?MaxRetentionSec.*/MaxRetentionSec=1year/g' /etc/ssh/sshd_config
