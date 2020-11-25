#!/bin/bash

set -eu

echo "Generating /etc/msmtprc and /etc/aliases."
flapctl config generate_templates
# Copy msmtprc.conf to the msmtp config folder.
cp "$FLAP_DIR/system/msmtprc.conf" /etc/msmtprc

if [ "${ADMIN_EMAIL:-}" != "" ]
then
    echo "root: $ADMIN_EMAIL" > /etc/aliases
fi
