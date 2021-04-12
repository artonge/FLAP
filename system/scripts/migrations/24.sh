#!/bin/bash

set -eux

# Version v1.14.7

echo "* [24] Update certbot hooks."
echo "flapctl stop nginx" > /etc/letsencrypt/renewal-hooks/pre/stop_flap.sh
echo "flapctl start nginx" > /etc/letsencrypt/renewal-hooks/post/start_flap.sh