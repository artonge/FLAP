#!/bin/bash

set -euo pipefail


debug "Generate domains specific config."
docker compose exec -T --user www-data nextcloud /inner_scripts/generate_post_domain_update_config.sh

for domain in $DOMAIN_NAMES
do
	get_saml_metadata nextcloud "$domain" "https://files.$domain/apps/user_saml/saml/metadata?idp=1"
done
