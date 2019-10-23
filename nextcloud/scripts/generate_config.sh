#!/bin/bash

set -eu

# Temporary enable the app store to allow installing apps.
php occ config:system:set appstoreenabled --value true --type boolean

# CHANGE DATA DIRECTORY
php occ config:system:set datadirectory --value '/data'

# ENABLE LDAP BACKEND
php occ app:enable user_ldap || true
php occ ldap:delete-config s01
php occ ldap:create-empty-config
php occ ldap:set-config s01 ldapHost ldap
php occ ldap:set-config s01 ldapPort 389
php occ ldap:set-config s01 ldapAgentName "cn=admin,dc=flap,dc=local"
php occ ldap:set-config s01 ldapAgentPassword "$ADMIN_PWD"
php occ ldap:set-config s01 ldapBase "$LDAP_BASE"
php occ ldap:set-config s01 ldapBaseUsers "$LDAP_BASE"
php occ ldap:set-config s01 ldapBaseGroups "$LDAP_BASE"
php occ ldap:set-config s01 ldapUserFilterObjectclass "inetOrgPerson"
php occ ldap:set-config s01 ldapUserFilter "(|(objectclass=inetOrgPerson))"
php occ ldap:set-config s01 ldapUserDisplayName "cn"
php occ ldap:set-config s01 ldapExpertUsernameAttr "uid"
php occ ldap:set-config s01 ldapLoginFilter "(&(|(objectclass=inetOrgPerson))(|(mail=%uid)(uid=%uid)))"
php occ ldap:set-config s01 ldapConfigurationActive 1
php occ ldap:set-config s01 ldapLoginFilterMode 1
php occ ldap:set-config s01 ldapEmailAttribute mail
php occ ldap:test-config s01

# ENABLE SAML
php occ app:enable user_saml || true
php occ config:app:set user_saml type --value "saml"
php occ config:app:set user_saml general-require_provisioned_account --value "1"
php occ config:app:set user_saml general-uid_mapping --value "uid"
php occ config:app:set user_saml general-idp0_display_name --value "FLAP SSO"
php occ config:app:set user_saml providerIds --value "1"
# HACK: there is a white space before the $(cat ...) because occ will interpret "-- BEGIN..." as a cli arg.
php occ config:app:set user_saml idp-x509cert --value " $(cat /saml/idp/cert.pem)"
php occ config:app:set user_saml sp-privateKey --value " $(cat /saml/nextcloud/private_key.pem)"
php occ config:app:set user_saml sp-x509cert --value " $(cat /saml/nextcloud/cert.pem)"
php occ config:app:set user_saml idp-entityId --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/metadata"
php occ config:app:set user_saml idp-singleSignOnService.url --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleSignOn"
php occ config:app:set user_saml idp-singleLogoutService.url --value "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleLogout"
php occ config:app:set user_saml sp-name-id-format --value "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
php occ config:app:set user_saml security-wantMessagesSigned --value "1",
php occ config:app:set user_saml security-logoutResponseSigned --value "1",
php occ config:app:set user_saml security-nameIdEncrypted --value "0",
php occ config:app:set user_saml security-wantNameIdEncrypted --value "0",
php occ config:app:set user_saml security-wantAssertionsEncrypted --value "0",
php occ config:app:set user_saml security-lowercaseUrlencoding --value "0",
php occ config:app:set user_saml security-wantXMLValidation --value "1",
php occ config:app:set user_saml security-wantNameId --value "1",
php occ config:app:set user_saml security-wantAssertionsSigned --value "1",
php occ config:app:set user_saml security-signMetadata --value "0",
php occ config:app:set user_saml security-logoutRequestSigned --value "1"

# CHOOSE CRON MODE
php occ background:cron

# SET TRUSTED DOMAINS
php occ config:system:delete trusted_domains
DOMAINS=($DOMAIN_NAMES)
for i in "${!DOMAINS[@]}"
do
    php occ config:system:set trusted_domains $i --value files.${DOMAINS[$i]}
done

# DISABLE FUNCTIONNALITIES
php occ config:system:set updatechecker --value false --type boolean
php occ config:system:set upgrade.disable-web --value true --type boolean
php occ config:system:set appstoreenabled --value false --type boolean

# CONFIGURE CACHE
php occ config:system:set memcache.local --value '\OC\Memcache\Redis'
php occ config:system:set memcache.locking --value '\OC\Memcache\Redis'
