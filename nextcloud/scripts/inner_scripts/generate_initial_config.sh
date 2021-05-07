#!/bin/bash

set -eu

# Temporary enable the app store to allow installing apps.
php occ --quiet config:system:set appstoreenabled --value true --type boolean

# CHANGE DATA DIRECTORY
php occ --quiet config:system:set datadirectory --value '/data'

# ENABLE LDAP BACKEND
php occ --quiet app:enable user_ldap
php occ --quiet ldap:create-empty-config
php occ --quiet ldap:set-config s01 ldapHost ldap
php occ --quiet ldap:set-config s01 ldapPort 389
php occ --quiet ldap:set-config s01 ldapAgentName "cn=admin,dc=flap,dc=local"
php occ --quiet ldap:set-config s01 ldapAgentPassword "$ADMIN_PWD"
php occ --quiet ldap:set-config s01 ldapBase "$LDAP_BASE"
php occ --quiet ldap:set-config s01 ldapBaseUsers "$LDAP_BASE"
php occ --quiet ldap:set-config s01 ldapBaseGroups "$LDAP_BASE"
php occ --quiet ldap:set-config s01 ldapUserFilterObjectclass "inetOrgPerson"
php occ --quiet ldap:set-config s01 ldapUserFilter "(|(objectclass=inetOrgPerson))"
php occ --quiet ldap:set-config s01 ldapUserDisplayName "cn"
php occ --quiet ldap:set-config s01 ldapExpertUsernameAttr "uid"
php occ --quiet ldap:set-config s01 ldapLoginFilter "(&(|(objectclass=inetOrgPerson))(|(mail=%uid)(uid=%uid)))"
php occ --quiet ldap:set-config s01 ldapConfigurationActive 1
php occ --quiet ldap:set-config s01 ldapLoginFilterMode 1
php occ --quiet ldap:set-config s01 ldapEmailAttribute mail
php occ --quiet ldap:test-config s01

# ENABLE SAML
php occ --quiet app:enable user_saml
php occ --quiet config:app:set user_saml type --value "saml"
php occ --quiet config:app:set user_saml general-require_provisioned_account --value "1"
php occ --quiet config:app:set user_saml general-uid_mapping --value "uid"
php occ --quiet config:app:set user_saml general-idp0_display_name --value "FLAP SSO"
php occ --quiet config:app:set user_saml providerIds --value "1"
php occ --quiet config:app:set user_saml sp-name-id-format --value "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
php occ --quiet config:app:set user_saml security-wantMessagesSigned --value "1",
php occ --quiet config:app:set user_saml security-logoutResponseSigned --value "1",
php occ --quiet config:app:set user_saml security-nameIdEncrypted --value "0",
php occ --quiet config:app:set user_saml security-wantNameIdEncrypted --value "0",
php occ --quiet config:app:set user_saml security-wantAssertionsEncrypted --value "0",
php occ --quiet config:app:set user_saml security-lowercaseUrlencoding --value "0",
php occ --quiet config:app:set user_saml security-wantXMLValidation --value "1",
php occ --quiet config:app:set user_saml security-wantNameId --value "1",
php occ --quiet config:app:set user_saml security-wantAssertionsSigned --value "1",
php occ --quiet config:app:set user_saml security-signMetadata --value "0",
php occ --quiet config:app:set user_saml security-logoutRequestSigned --value "1"

# CHOOSE CRON MODE
php occ --quiet background:cron

# ENABLE PREVIEW PRE-GENERATOR
php occ --quiet app:enable previewgenerator

# ENABLE RANSOMWARE PLUGINS
php occ --quiet app:enable ransomware_protection

# ENABLE COLLABORA
if echo "$FLAP_SERVICES" | grep collabora
then
	php occ --quiet app:install richdocuments
fi

# MAIL
php occ --quiet config:system:set mail_smtpmode --value "smtp"
php occ --quiet config:system:set mail_sendmailmode --value "smtp"
php occ --quiet config:system:set mail_from_address --value "admin"
php occ --quiet config:system:set mail_smtpauthtype --value "PLAIN"
php occ --quiet config:system:set mail_smtpauth --value 1 --type integer
php occ --quiet config:system:set mail_smtpport --value "587"
php occ --quiet config:system:set mail_smtpname --value "admin"
php occ --quiet config:system:set mail_smtppassword --value "$ADMIN_PWD"
php occ --quiet config:system:set mail_smtpsecure --value "tls"

# DISABLE DASHBOARD
php occ --quiet app:disable dashboard

# DISABLE FUNCTIONALITIES
php occ --quiet config:system:set upgrade.disable-web --value true --type boolean

# CONFIGURE CACHE
php occ --quiet config:system:set memcache.local --value '\OC\Memcache\Redis'
php occ --quiet config:system:set memcache.locking --value '\OC\Memcache\Redis'
