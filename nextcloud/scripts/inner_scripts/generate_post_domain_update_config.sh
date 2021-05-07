#!/bin/bash

set -eu

# ENABLE SAML
# HACK: there is a white space before the $(cat ...) because occ will interpret "-- BEGIN..." as a cli arg.
php occ --quiet config:app:set user_saml idp-x509cert --value " $(cat /saml/idp/cert.pem)"
php occ --quiet config:app:set user_saml sp-privateKey --value " $(cat /saml/nextcloud/private_key.pem)"
php occ --quiet config:app:set user_saml sp-x509cert --value " $(cat /saml/nextcloud/cert.pem)"
php occ --quiet config:app:set user_saml idp-entityId --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/metadata"
php occ --quiet config:app:set user_saml idp-singleSignOnService.url --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleSignOn"
php occ --quiet config:app:set user_saml idp-singleLogoutService.url --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleLogout"

# SET TRUSTED DOMAINS
php occ --quiet config:system:delete trusted_domains
read -r -a DOMAINS <<< "$DOMAIN_NAMES"
for i in "${!DOMAINS[@]}"
do
    php occ --quiet config:system:set trusted_domains "$i" --value files."${DOMAINS[$i]}"
done

# SET ONLYOFFICE DOMAIN
if [ "$ARCH" == "x86_64" ] && [ "${FLAG_NO_DOCUMENTSERVER:-}" != "true" ]
then
	php occ --quiet config:app:set onlyoffice DocumentServerUrl --value "https://files.$PRIMARY_DOMAIN_NAME/index.php/apps/documentserver_community/"
fi

# MAIL
php occ --quiet config:system:set mail_domain --value "$PRIMARY_DOMAIN_NAME"
php occ --quiet config:system:set mail_smtphost --value "$PRIMARY_DOMAIN_NAME"
