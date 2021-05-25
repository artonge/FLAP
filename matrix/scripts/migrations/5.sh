#!/bin/bash

set -eu

# Version 1.14.7

echo "* [5] Use environment variables for MATRIX_DOMAIN_NAME."
echo "export MATRIX_DOMAIN_NAME=$MATRIX_DOMAIN_NAME" >> "$FLAP_DATA/system/flapctl.env"
rm "$FLAP_DATA/matrix/domain.txt"

echo "* [5] Update Synapse's SAML metadata."
flapctl start matrix lemon nginx
flapctl exec matrix hooks/post_domain_update
flapctl stop
