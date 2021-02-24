#!/bin/bash

set -eu

# Check certificates with local CA for local domains.
provider=$(cat "$FLAP_DATA/system/data/domains/$MATRIX_DOMAIN_NAME/provider.txt")
if [ "$provider" == "local" ]
then
	ca_cert=(--cacert /etc/letsencrypt/live/flap/root.cer)
fi

echo "Fetching synapse SAML metadata."
curl "https://matrix.$MATRIX_DOMAIN_NAME/_matrix/saml2/metadata.xml" --output "$FLAP_DATA/matrix/saml/metadata_$MATRIX_DOMAIN_NAME.xml" "${ca_cert[@]}"
