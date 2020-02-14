#!/bin/bash

set -eu

# Install msmtp to send mail from cmd line.
apt install -y msmtp msmtp-mta

# Create msmtp config.
flapctl config generate_mails
cp "$FLAP_DIR"/system/msmtprc.conf /etc/msmtprc
echo "root: louis@chmn.me" > /etc/msmrprc.aliases
