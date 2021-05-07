#!/bin/bash

set -eu

# v1.14.7

echo "* [1] Use environment variables for FUNKWHALE_DOMAIN_NAME."
echo "export FUNKWHALE_DOMAIN_NAME=$FUNKWHALE_DOMAIN_NAME" >> "$FLAP_DATA/system/flapctl.env"
rm "$FLAP_DATA/funkwhale/domain.txt"