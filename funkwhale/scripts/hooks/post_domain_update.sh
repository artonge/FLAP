#!/bin/bash

set -eu

echo "Getting SAML metadata for funkwhale."
# Check certificates with local CA for local FUNKWHALE_DOMAIN_NAMEs.
provider=$(cat "$FLAP_DATA/system/data/domains/$FUNKWHALE_DOMAIN_NAME/provider.txt")
if [ "$provider" == "local" ]
then
	ca_cert=(--cacert /etc/letsencrypt/live/flap/root.cer)
fi

curl "https://video.$FUNKWHALE_DOMAIN_NAME/plugins/auth-saml2/router/metadata.xml" --output "$FLAP_DATA/funkwhale/saml/metadata_$FUNKWHALE_DOMAIN_NAME.xml" "${ca_cert[@]}"
