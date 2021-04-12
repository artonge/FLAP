#!/bin/bash

set -eu

echo "Install SAML auth plugin."
docker-compose exec -T peertube npm run plugin:install -- --npm-name peertube-plugin-auth-saml2 --plugin-version "$PEERTUBE_SAML_PLUGIN_VERSION"

echo "Update auth-saml2 plugin config."
saml_config=$(jq \
	--null-input \
	--arg provider_cert "$(cat "$FLAP_DATA/lemon/saml/cert.pem")" \
	--arg service_cert "$(cat "$FLAP_DATA/peertube/saml/cert.pem")" \
	--arg service_priv_key "$(cat "$FLAP_DATA/peertube/saml/private_key.pem")" \
	--from-file "$FLAP_DIR/peertube/config/saml_config.jq"
)

docker-compose exec -T --user postgres postgres psql peertube --command "UPDATE public.plugin SET settings='$saml_config' WHERE name='auth-saml2';"

# Restart peertube so the plugin is activated.
flapctl restart peertube
