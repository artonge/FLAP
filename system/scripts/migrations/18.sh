#!/bin/bash

set -euo pipefail

# Version v1.13.0

echo "* [18] Migrating some environment variables to flapctl.env."

echo "export ADMIN_EMAIL=$ADMIN_EMAIL" >> "$FLAP_DATA/system/flapctl.env"
rm -rf "$FLAP_DATA/system/admin_email.txt"

echo "export ENABLE_MONITORING=$ENABLE_MONITORING" >> "$FLAP_DATA/system/flapctl.env"
rm -rf "$FLAP_DATA/system/flap.yml"
