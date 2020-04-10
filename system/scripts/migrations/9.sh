#!/bin/bash

set -eu

echo "* [9] Remove 'export' statements from /etc/environment"
echo "FLAP_DIR=$FLAP_DIR" > /etc/environment
echo "FLAP_DATA=$FLAP_DATA" >> /etc/environment
echo "COMPOSE_HTTP_TIMEOUT=120" >> /etc/environment

echo "* [9] Copy and enable flap.service"
cp "$FLAP_DIR/system/flap.service" /etc/systemd/system

if [ "$(command -v systemctl || true)" != "" ]
then
    systemctl enable flap
fi
