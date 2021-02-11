#!/bin/bash

set -eu

echo "Install SAML auth plugin."
# If you bump the plugin version, please update home/apps.ts and add a migration to upgrade the plugin on live instances.
# The SAML plugin version is fixed for two reason:
# 	- It allows one click connection from the FLAP home's view.
# 	- Plugins updates are not automated for now so we would need to update them manually anyway.
docker-compose run -T peertube npm run plugin:install -- --npm-name peertube-plugin-auth-saml2 --plugin-version 0.0.4

echo "Update auth-saml2 plugin config."
saml_config=$(jq \
	--null-input \
	--arg provider_cert "$(cat "$FLAP_DATA/lemon/saml/cert.pem")" \
	--arg service_cert "$(cat "$FLAP_DATA/peertube/saml/cert.pem")" \
	--arg service_priv_key "$(cat "$FLAP_DATA/peertube/saml/private_key.pem")" \
	--from-file "$FLAP_DIR/peertube/config/saml_config.jq"
)

docker-compose exec -T --user postgres postgres psql peertube --command "UPDATE public.plugin SET settings='$saml_config' WHERE name='auth-saml2';"
