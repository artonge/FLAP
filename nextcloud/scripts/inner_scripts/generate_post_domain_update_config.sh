#!/bin/bash

set -euo pipefail

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=("${args[@]}")
fi

# ENABLE SAML
# HACK: there is a white space before the $(cat ...) because occ will interpret "-- BEGIN..." as a cli arg.
php ./occ saml:config:set 1 \
	--idp-x509cert " $(cat /saml/idp/cert.pem)" \
	--sp-privateKey " $(cat /saml/nextcloud/private_key.pem)" \
	--sp-x509cert " $(cat /saml/nextcloud/cert.pem)" \
	--idp-entityId "https://auth.$PRIMARY_DOMAIN_NAME/saml/metadata" \
	--idp-singleSignOnService.url "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleSignOn" \
	--idp-singleLogoutService.url "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleLogout"

# SET TRUSTED DOMAINS
php occ "${args[@]}" config:system:delete trusted_domains
read -r -a DOMAINS <<< "$DOMAIN_NAMES"
for i in "${!DOMAINS[@]}"
do
    php occ "${args[@]}" config:system:set trusted_domains "$i" --value files."${DOMAINS[$i]}"
done

# SET COLLABORA DOMAIN
if echo "$FLAP_SERVICES" | grep collabora
then
	php occ "${args[@]}" app:install richdocuments

	php occ "${args[@]}" config:app:set richdocuments wopi_url --value "https://office.$PRIMARY_DOMAIN_NAME"
	php occ "${args[@]}" config:app:set richdocuments public_wopi_url --value "https://office.$PRIMARY_DOMAIN_NAME"
	php occ "${args[@]}" config:app:set richdocuments disable_certificate_verification --value "no"

	if [ "$PRIMARY_DOMAIN_NAME" == "flap.test" ]
	then
		php occ --quiet config:app:set richdocuments disable_certificate_verification --value "yes"
	fi
fi

# MAIL
php occ "${args[@]}" config:system:set mail_domain --value "$PRIMARY_DOMAIN_NAME"
php occ "${args[@]}" config:system:set mail_smtphost --value "$PRIMARY_DOMAIN_NAME"
