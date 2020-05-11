#!/bin/bash

set -eu

# Version v1.7.1

echo "* [14] Install openssl libs."
apt-get install -y libssl-dev

echo "* [14] Update docker-compose."
pip3 install -U docker-compose

echo "* [14] Remove deprecated static IP file."
rm --force "$FLAP_DATA/system/data/fixed_ip.txt"
