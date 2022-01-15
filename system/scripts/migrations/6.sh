#!/bin/bash

set -euo pipefail

apt install wget

# Setting certbot hooks.
mkdir -p /etc/letsencrypt/renewal-hooks/pre
mkdir -p /etc/letsencrypt/renewal-hooks/post
echo "flapctl stop" > /etc/letsencrypt/renewal-hooks/pre/stop_flap.sh
echo "flapctl start" > /etc/letsencrypt/renewal-hooks/post/start_flap.sh
chmod +x /etc/letsencrypt/renewal-hooks/pre/stop_flap.sh
chmod +x /etc/letsencrypt/renewal-hooks/post/start_flap.sh
