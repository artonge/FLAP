#!/bin/bash

set -eu

# v1.14.7

echo "* [6] Use environment variables for MATRIX_DOMAIN_NAME."
echo "export MATRIX_DOMAIN_NAME=$MATRIX_DOMAIN_NAME" >> "$FLAP_DATA/system/flapctl.env"
rm "$FLAP_DATA/matrix/domain.txt"