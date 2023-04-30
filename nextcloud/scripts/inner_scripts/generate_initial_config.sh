#!/bin/bash

set -euo pipefail


if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=("${args[@]}")
fi

# CHANGE DATA DIRECTORY
php occ "${args[@]}" config:system:set datadirectory --value '/data'

# ENABLE LDAP BACKEND
php occ "${args[@]}" app:enable user_ldap
php occ "${args[@]}" ldap:create-empty-config
php occ "${args[@]}" ldap:set-config s01 ldapHost ldap
php occ "${args[@]}" ldap:set-config s01 ldapPort 389
php occ "${args[@]}" ldap:set-config s01 ldapAgentName "cn=admin,dc=flap,dc=local"
php occ "${args[@]}" ldap:set-config s01 ldapAgentPassword "$ADMIN_PWD"
php occ "${args[@]}" ldap:set-config s01 ldapBase "$LDAP_BASE"
php occ "${args[@]}" ldap:set-config s01 ldapBaseUsers "$LDAP_BASE"
php occ "${args[@]}" ldap:set-config s01 ldapBaseGroups "$LDAP_BASE"
php occ "${args[@]}" ldap:set-config s01 ldapUserFilterObjectclass "inetOrgPerson"
php occ "${args[@]}" ldap:set-config s01 ldapUserFilter "(|(objectclass=inetOrgPerson))"
php occ "${args[@]}" ldap:set-config s01 ldapUserDisplayName "cn"
php occ "${args[@]}" ldap:set-config s01 ldapExpertUsernameAttr "uid"
php occ "${args[@]}" ldap:set-config s01 ldapLoginFilter "(&(|(objectclass=inetOrgPerson))(|(mail=%uid)(uid=%uid)))"
php occ "${args[@]}" ldap:set-config s01 ldapConfigurationActive 1
php occ "${args[@]}" ldap:set-config s01 ldapLoginFilterMode 1
php occ "${args[@]}" ldap:set-config s01 ldapEmailAttribute mail
php occ "${args[@]}" ldap:test-config s01

# ENABLE SAML
php occ "${args[@]}" app:enable user_saml
php occ "${args[@]}" saml:config:create
php occ "${args[@]}" config:app:set user_saml type --value "saml"
php occ "${args[@]}" config:app:set user_saml general-require_provisioned_account --value "1"
php occ "${args[@]}" saml:config:set 1 \
    --general-uid_mapping "uid" \
    --general-idp0_display_name "FLAP SSO" \
    --sp-name-id-format "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress" \
    --security-wantMessagesSigned "1", \
    --security-logoutResponseSigned "1", \
    --security-nameIdEncrypted "0", \
    --security-wantNameIdEncrypted "0", \
    --security-wantAssertionsEncrypted "0", \
    --security-lowercaseUrlencoding "0", \
    --security-wantXMLValidation "1", \
    --security-wantNameId "1", \
    --security-wantAssertionsSigned "1", \
    --security-signMetadata "0", \
    --security-logoutRequestSigned "1"

# CHOOSE CRON MODE
php occ "${args[@]}" background:cron

# ENABLE PREVIEW PRE-GENERATOR
php occ "${args[@]}" app:enable previewgenerator

# ENABLE RANSOMWARE PLUGINS
php occ "${args[@]}" app:enable ransomware_protection

# MAIL
php occ "${args[@]}" config:system:set mail_smtpmode --value "smtp"
php occ "${args[@]}" config:system:set mail_sendmailmode --value "smtp"
php occ "${args[@]}" config:system:set mail_from_address --value "admin"
php occ "${args[@]}" config:system:set mail_smtpauthtype --value "PLAIN"
php occ "${args[@]}" config:system:set mail_smtpauth --value 1 --type integer
php occ "${args[@]}" config:system:set mail_smtpport --value "587"
php occ "${args[@]}" config:system:set mail_smtpname --value "admin"
php occ "${args[@]}" config:system:set mail_smtppassword --value "$ADMIN_PWD"
php occ "${args[@]}" config:system:set mail_smtpsecure --value "tls"

# DISABLE DASHBOARD
php occ "${args[@]}" app:disable dashboard

# DISABLE FUNCTIONALITIES
php occ "${args[@]}" config:system:set updatechecker --value false --type boolean
php occ "${args[@]}" config:system:set upgrade.disable-web --value true --type boolean

# CONFIGURE CACHE
php occ "${args[@]}" config:system:set memcache.local --value '\OC\Memcache\Redis'
php occ "${args[@]}" config:system:set memcache.locking --value '\OC\Memcache\Redis'
