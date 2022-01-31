#!/bin/bash

set -euo pipefail

# Usage: ./flap.sh <domain name>

DOMAIN=$1
TOKEN=$(cat "$FLAP_DATA/system/data/domains/$DOMAIN/authentication.txt")

echo "* [dns-update:flap] Updating flap DNS for $DOMAIN."

# shellcheck disable=SC2002
if [ -f "$FLAP_DIR/mail/config/opendkim/keys/$DOMAIN/mail.txt" ]
then
	dkim=$(cat "$FLAP_DIR/mail/config/opendkim/keys/$DOMAIN/mail.txt" | tr "\n" " " | grep --only-matching --extended-regexp 'p=.+"' | tr '"\t' ' ' | sed 's/[[:space:]]//g')
fi

{
	wget \
		--method PATCH \
		--header "Content-Type: application/json" \
		--body-data "{
			\"token\": \"$TOKEN\",
			\"ip4\": \"$(flapctl ip external)\",
			\"dkim\": \"${dkim:-}\"
		}" \
		--quiet \
		--output-document=- \
		--content-on-error \
		"https://flap.id/domains/$DOMAIN"
} || {
	exit_code=1
}

echo ""

exit "$exit_code"
