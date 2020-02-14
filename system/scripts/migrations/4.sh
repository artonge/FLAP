#!/bin/bash

set -eu

# Change flapctl's name for flapctl.
ln -sf "$FLAP_DIR"/system/cli/flapctl.sh /bin/flapctl

# Run post_install script for mail.
mkdir -p "$FLAP_DATA"/mail/data
cat "$FLAP_DIR"/mail/scripts/migrations/base_migration.txt > "$FLAP_DATA"/mail/current_migration.txt
"$FLAP_DIR"/mail/scripts/hooks/post_install.sh

# Open ports
flapctl setup network

# Regenerate TLS certificates for new subdomain: mail.{...}.
flapctl tls generate

# Uninstall postfix and dovecot.
apt remove -y postfix dovecot
apt purge -y postfix dovecot
apt autoremove

# Increase compose timeout for slow connexion.
echo "export COMPOSE_HTTP_TIMEOUT=120" >> /etc/environment
