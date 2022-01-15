#!/bin/bash

set -euo pipefail

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=("${args[@]}")
fi

# ENABLE SAML
# HACK: there is a white space before the $(cat ...) because occ will interpret "-- BEGIN..." as a cli arg.
php occ "${args[@]}" config:app:set user_saml idp-x509cert --value " $(cat /saml/idp/cert.pem)"
php occ "${args[@]}" config:app:set user_saml sp-privateKey --value " $(cat /saml/nextcloud/private_key.pem)"
php occ "${args[@]}" config:app:set user_saml sp-x509cert --value " $(cat /saml/nextcloud/cert.pem)"
php occ "${args[@]}" config:app:set user_saml idp-entityId --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/metadata"
php occ "${args[@]}" config:app:set user_saml idp-singleSignOnService.url --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleSignOn"
php occ "${args[@]}" config:app:set user_saml idp-singleLogoutService.url --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleLogout"

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
