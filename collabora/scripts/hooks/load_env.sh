#!/bin/bash

set -eu

FLAP_ENV_VARS="$FLAP_ENV_VARS \${COLLABORA_EXTRA_PARAMS}"
SUBDOMAINS="$SUBDOMAINS office"

export COLLABORA_EXTRA_PARAMS
COLLABORA_EXTRA_PARAMS='--o:welcome.enable=false --o:ssl.cert_file_path=/etc/letsencrypt/live/flap/fullchain.pem --o:ssl.key_file_path=/etc/letsencrypt/live/flap/privkey.pem'

primary_domain_provider=$(cat "$FLAP_DATA/system/data/domains/$PRIMARY_DOMAIN_NAME/provider.txt")
if [ "$primary_domain_provider" == "localhost" ] || [ "$primary_domain_provider" == "local" ]
then
	COLLABORA_EXTRA_PARAMS+='--o:ssl.ca_file_path=/etc/letsencrypt/live/flap/root.cer'
fi