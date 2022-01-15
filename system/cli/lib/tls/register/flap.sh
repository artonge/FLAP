#!/bin/bash

set -euo pipefail

# Usage: ./flap.sh <domain name>

DOMAIN=$1
TOKEN=$(cat "$FLAP_DATA/system/data/domains/$DOMAIN/authentication.txt")

echo "* [dns-register:flap] Registering $DOMAIN to flap.id DNS."

# HACK: wget output does not contain a new line, so the log is weird.
# We can not exec an 'echo ""' because when it fails the script return ealry.
# We add a `| cat` to prevent exiting early on error.
# Then we catch the error code with PIPESTATUS, exec `echo ""` and return the exit code.
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
	https://flap.id/domains | cat

# Catch error code
exit_code=${PIPESTATUS[0]}

echo ""

if [ "$exit_code" != 0 ]
then
	echo "* [dns-register:flap] Error while registering the domain."
	exit "$exit_code"
fi
