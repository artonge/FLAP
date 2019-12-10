#!/bin/bash

set -eu

# Run post_install script for mail.
mkdir -p $FLAP_DATA/mail/data
cat $FLAP_DIR/mail/scripts/migrations/base_migration.txt > $FLAP_DATA/mail/current_migration.txt
$FLAP_DIR/mail/scripts/hooks/post_install.sh

# Open ports
manager setup network

# Regenerate TLS certificates for new subdomain: mail.{...}.
manager tls generate

# Uninstall postfix and dovecot.
apt remove -y postfix dovecot
apt purge -y postfix dovecot
apt autoremove
