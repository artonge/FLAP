#!/bin/bash

set -eu

# Usage: ./duckdns.sh <domain name>

DOMAIN=$1
TOKEN=$(cat $FLAP_DATA/system/data/domains/$DOMAIN/authentication.txt)

echo "* [dns-update:duckdns] Updating duckdns DNS for $DOMAIN."

curl "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&verbose=true"
