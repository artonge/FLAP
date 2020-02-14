#!/bin/bash

set -eu

# Install jq to manipulate JSON files.
apt update
apt install -y jq psmisc

# Run post_install script for lemon.
mkdir -p "$FLAP_DATA"/lemon/data
cat "$FLAP_DIR"/lemon/scripts/migrations/base_migration.txt > "$FLAP_DATA"/lemon/current_migration.txt
"$FLAP_DIR"/lemon/scripts/hooks/post_install.sh

# Generate auth.$DOMAIN tls certs.
flapctl tls generate
