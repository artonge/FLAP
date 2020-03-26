#!/bin/bash

# ./reinstall.sh v1.0.14

set -eux

TAG=$1

flapctl stop
flapctl clean -y

rm -rf "$FLAP_DIR"
rm -rf "$FLAP_DATA"

apt remove -y docker-ce docker-ce-cli containerd.io
apt purge  -y docker-ce docker-ce-cli containerd.io

rm ~/install_flap.sh
curl "https://gitlab.com/flap-box/flap/raw/$TAG/system/img_build/userpatches/overlay/install_flap.sh" > ~/install_flap.sh
chmod +x ~/install_flap.sh
~/install_flap.sh "$TAG"

manager start
