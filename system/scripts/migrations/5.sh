#!/bin/bash

set -eu

# Install msmtp to send mail from cmd line.
apt install -y msmtp msmtp-mta

# Generate msmtprc.conf template.
flapctl config generate_templates

# Copy msmtprc.conf to the msmtp config folder.
cp "$FLAP_DIR/system/msmtprc.conf" /etc/msmtprc
echo "root: louis@chmn.me" > /etc/msmtp.aliases
