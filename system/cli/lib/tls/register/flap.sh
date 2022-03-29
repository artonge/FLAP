#!/bin/bash

set -euo pipefail

# Usage: ./flap.sh <domain name>

DOMAIN=$1
TOKEN=$(cat "$FLAP_DATA/system/data/domains/$DOMAIN/authentication.txt")

exit_code=0

echo "* [dns-register:flap] Registering $DOMAIN to flap.id DNS."

{
	wget \
		--method POST \
		--header "Content-Type: application/json" \
		--body-data "{
			\"name\": \"$DOMAIN\",
			\"token\": \"$TOKEN\"
		}" \
		--quiet \
		--output-document=- \
		--content-on-error \
		https://flap.id/domains
} || {
	echo "* [dns-register:flap] Error while registering the domain."
	exit_code=1
}

echo ""

exit "$exit_code"
