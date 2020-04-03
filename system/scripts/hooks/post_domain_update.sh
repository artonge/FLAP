#!/bin/bash

set -eu

echo "Generating /etc/msmtprc and /etc/msmtp.aliases."
flapctl config generate_templates
# Copy msmtprc.conf to the msmtp config folder.
cp "$FLAP_DIR/system/msmtprc.conf" /etc/msmtprc
echo "root: louis@chmn.me" > /etc/msmtp.aliases
