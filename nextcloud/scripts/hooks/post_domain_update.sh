#!/bin/bash

set -eu

# Wait for nextcloud to be ready
"$FLAP_DIR/nextcloud/scripts/wait_ready.sh"

# Generate config.php with the new config
docker-compose exec -T --user www-data nextcloud /inner_scripts/generate_post_domain_update_config.sh

# Don't do it during CI.
if [ "${CI:-false}" == "false" ]
then
    # Get SAML metadata for each domains.
    echo "$DOMAIN_NAMES"
    for domain in $DOMAIN_NAMES
    do
        # HACK: don't check TLS certificates during developement.
        if [ "${DEV:-false}" == "true" ]
        then
            curl "https://files.$domain/apps/user_saml/saml/metadata?idp=1" --insecure --output "$FLAP_DATA/nextcloud/saml//metadata_$domain.xml"
        else
            curl "https://files.$domain/apps/user_saml/saml/metadata?idp=1" --output "$FLAP_DATA/nextcloud/saml//metadata_$domain.xml"
        fi
    done
fi
