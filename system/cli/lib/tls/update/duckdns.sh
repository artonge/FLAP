#!/bin/bash

set -eu

# Usage: ./duckdns.sh <domain name>

echo '* [dns-update:duckdns] Updating duckdns DNS.'

DOMAIN=$1
TOKEN=$(cat $FLAP_DATA/system/data/domains/$DOMAIN/authentication.txt)

curl "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&verbose=true"