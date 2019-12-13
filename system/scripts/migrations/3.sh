#!/bin/bash

set -eu

# Change manager's name for flapctl.
rm /bin/manager
ln -sf $FLAP_DIR/system/cli/flapctl.sh /bin/flapctl

# Run post_install script for mail.
mkdir -p $FLAP_DATA/mail/data
cat $FLAP_DIR/mail/scripts/migrations/base_migration.txt > $FLAP_DATA/mail/current_migration.txt
$FLAP_DIR/mail/scripts/hooks/post_install.sh

# Open ports
flapctl setup network

# Regenerate TLS certificates for new subdomain: mail.{...}.
flapctl tls generate

# Uninstall postfix and dovecot.
apt remove -y postfix dovecot
apt purge -y postfix dovecot
apt autoremove


# Install yq.
pip3 install yq
