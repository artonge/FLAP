#!/bin/bash

set -eux

# CHANGE DATA DIRECTORY
php occ config:system:set datadirectory --value '/data'

# ENABLE APPS
php occ app:enable user_ldap || true

# CHOOSE CRON MODE
php occ background:cron

# SET TRUSTED DOMAINS
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

# CONFIGURE LDAP
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
php occ ldap:set-config s01 ldapLoginFilter "(&(|(objectclass=inetOrgPerson))(|(mail=%uid)(sn=%uid)))"
php occ ldap:set-config s01 ldapConfigurationActive 1
php occ ldap:set-config s01 ldapLoginFilterMode 1
php occ ldap:set-config s01 ldapEmailAttribute mail
php occ ldap:test-config s01
