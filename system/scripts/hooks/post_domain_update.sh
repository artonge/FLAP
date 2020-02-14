#!/bin/bash

set -eu

# Generate msmtprc.conf.
flapctl config generate_templates
# Copy msmtprc.conf to the msmtp config folder.
cp "$FLAP_DIR/system/msmtprc.conf" /etc/msmtprc
echo "root: louis@chmn.me" > /etc/msmtp.aliases
