#!/bin/bash

set -eu

# Touch installed.txt file for all services except for matrix.
for service in "$FLAP_DATA"/*
do
	if [ "$(basename "$service")" == "matrix" ] || [ "$(basename "$service")" == "jitsi" ]
	then
		continue
	fi

	echo "* [8] Marking $(basename "$service") as installed."
	touch "$service/installed.txt"
done

echo "* [8] Updating tls certificates for new subdomains."
flapctl tls generate

provider=$(cat "$FLAP_DATA/system/data/domains/$PRIMARY_DOMAIN_NAME/provider.txt")
if [ "$provider" == "local" ]
then
	# Generate certificates for flap.test.
	flapctl tls generate_localhost
fi

echo "* [8] Install ufw."
apt install -y ufw
