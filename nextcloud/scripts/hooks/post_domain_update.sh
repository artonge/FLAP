#!/bin/bash

set -eu

debug "Generate domains specific config."
docker-compose exec -T --user www-data nextcloud /inner_scripts/generate_post_domain_update_config.sh

debug "Getting SAML metadata for each domains."
for domain in $DOMAIN_NAMES
do
	# Check certificates with local CA for local domains.
	provider=$(cat "$FLAP_DATA/system/data/domains/$domain/provider.txt")
	if [ "$provider" == "local" ]
	then
		ca_cert=(--cacert /etc/letsencrypt/live/flap/root.cer)
	fi

	echo "Fetching Nextcloud SAML metadata for $domain."
	curl "https://files.$domain/apps/user_saml/saml/metadata?idp=1" --output "$FLAP_DATA/nextcloud/saml/metadata_$domain.xml" "${ca_cert[@]}"
done
