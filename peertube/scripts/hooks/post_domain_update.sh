#!/bin/bash

set -eu

echo "Getting SAML metadata for peertube."
# Check certificates with local CA for local PEERTUBE_DOMAIN_NAMEs.
provider=$(cat "$FLAP_DATA/system/data/domains/$PEERTUBE_DOMAIN_NAME/provider.txt")
if [ "$provider" == "local" ]
then
	ca_cert=(--cacert /etc/letsencrypt/live/flap/root.cer)
fi

curl "https://video.$PEERTUBE_DOMAIN_NAME/plugins/auth-saml2/router/metadata.xml" --output "$FLAP_DATA/peertube/saml/metadata_$PEERTUBE_DOMAIN_NAME.xml" "${ca_cert[@]}"
