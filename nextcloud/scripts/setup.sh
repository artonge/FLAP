#!/bin/bash

# set -e

# ENABLE APPS
php occ app:enable user_ldap
php occ app:install calendar
php occ app:install contacts

# CHOOSE CRON MODE
php occ background:cron

# SET TRUSTED DOMAINS
php occ config:system:set trusted_domains 0 --value files.$DOMAIN_NAME

# DISABLE FUNCTIONNALITIES
php occ config:system:set updatechecker --value false --type boolean
php occ config:system:set upgrade.disable-web --value true --type boolean
php occ config:system:set appstoreenabled --value false --type boolean

# CONNECT TO REDIS
php occ config:system:set redis host --value redis
php occ config:system:set redis port --value 6379 --type integer
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
php occ ldap:set-config s01 ldapLoginFilter "(&(objectclass=*)(|(mailPrimaryAddress=%uid)(mail=%uid)))"
php occ ldap:test-config s01
