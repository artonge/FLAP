#!/bin/bash

set -euo pipefail

# Version v1.14.0

echo "* [20] Migrate aliases file from /etc/msmtp.aliases to /etc/aliases."
flapctl config generate_templates
# Sync /etc/msmtprc.
cp "$FLAP_DIR/system/msmtprc.conf" /etc/msmtprc
# Migrate aliases file.
rm -rf /etc/msmtp.aliases
echo "root: ${ADMIN_EMAIL:-}" > /etc/aliases
