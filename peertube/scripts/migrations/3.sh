#!/bin/bash

set -eu

# v1.14.7

echo "* [3] Use environment variables for PEERTUBE_DOMAIN_NAME."
echo "export PEERTUBE_DOMAIN_NAME=$PEERTUBE_DOMAIN_NAME" >> "$FLAP_DATA/system/flapctl.env"
rm "$FLAP_DATA/peertube/domain.txt"