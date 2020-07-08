#!/bin/bash

set -eu

# ENABLE SAML
# HACK: there is a white space before the $(cat ...) because occ will interpret "-- BEGIN..." as a cli arg.
php occ config:app:set user_saml idp-x509cert --value " $(cat /saml/idp/cert.pem)"
php occ config:app:set user_saml sp-privateKey --value " $(cat /saml/nextcloud/private_key.pem)"
php occ config:app:set user_saml sp-x509cert --value " $(cat /saml/nextcloud/cert.pem)"
php occ config:app:set user_saml idp-entityId --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/metadata"
php occ config:app:set user_saml idp-singleSignOnService.url --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleSignOn"
php occ config:app:set user_saml idp-singleLogoutService.url --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleLogout"

# SET TRUSTED DOMAINS
php occ config:system:delete trusted_domains
read -r -a DOMAINS <<< "$DOMAIN_NAMES"
for i in "${!DOMAINS[@]}"
do
    php occ config:system:set trusted_domains "$i" --value files."${DOMAINS[$i]}"
done

# MAIL
php occ config:system:set mail_domain --value "$PRIMARY_DOMAIN_NAME"
php occ config:system:set mail_smtphost --value "$PRIMARY_DOMAIN_NAME"
