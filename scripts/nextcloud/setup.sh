#!/bin/bash

# set -e

# ENABLE APPS
docker-compose exec --user www-data nextcloud php occ app:enable user_ldap
docker-compose exec --user www-data nextcloud php occ app:install calendar
docker-compose exec --user www-data nextcloud php occ app:install contacts

# CHOOSE CRON MODE
docker-compose exec --user www-data nextcloud php occ background:cron

# SET TRUSTED DOMAINS
docker-compose exec --user www-data nextcloud php occ config:system:set trusted_domains 0 --value files.flap.localhost

# DISABLE FUNCTIONNALITIES
docker-compose exec --user www-data nextcloud php occ config:system:set updatechecker --value false --type boolean
docker-compose exec --user www-data nextcloud php occ config:system:set upgrade.disable-web --value true --type boolean
docker-compose exec --user www-data nextcloud php occ config:system:set appstoreenabled --value false --type boolean

# CONNECT TO REDIS
docker-compose exec --user www-data nextcloud php occ config:system:set redis host --value redis
docker-compose exec --user www-data nextcloud php occ config:system:set redis port --value 6379 --type integer
docker-compose exec --user www-data nextcloud php occ config:system:set memcache.local --value '\OC\Memcache\Redis'
docker-compose exec --user www-data nextcloud php occ config:system:set memcache.locking --value '\OC\Memcache\Redis'

# CONFIGURE LDAP
docker-compose exec --user www-data nextcloud php occ ldap:create-empty-config
docker-compose exec --user www-data nextcloud php occ ldap:set-config s01 ldapHost ldap
docker-compose exec --user www-data nextcloud php occ ldap:set-config s01 ldapPort ldap
docker-compose exec --user www-data nextcloud php occ ldap:set-config s01 ldapAgentName "cn=admin,dc=example,dc=org"
docker-compose exec --user www-data nextcloud php occ ldap:set-config s01 ldapAgentPassword admin
docker-compose exec --user www-data nextcloud php occ ldap:set-config s01 ldapBase "dc=example,dc=org"
