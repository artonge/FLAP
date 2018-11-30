#!/bin/bash

# APPS
# docker-compose exec --user www-data nextcloud php occ app:enable user_ldap
docker-compose exec --user www-data nextcloud php occ app:install calendar
docker-compose exec --user www-data nextcloud php occ app:install contacts

# BACKGROUND
docker-compose exec --user www-data nextcloud php occ background:cron

# TRUSTED DOMAINS
docker-compose exec --user www-data nextcloud php occ config:system:set trusted_domains 0 --value files.flap.localhost

# FUNCTIONNALITIES
docker-compose exec --user www-data nextcloud php occ config:system:set updatechecker --value false --type boolean
docker-compose exec --user www-data nextcloud php occ config:system:set upgrade.disable-web --value true --type boolean
docker-compose exec --user www-data nextcloud php occ config:system:set appstoreenabled --value false --type boolean

# REDIS
docker-compose exec --user www-data nextcloud php occ config:system:set redis host --value redis
docker-compose exec --user www-data nextcloud php occ config:system:set redis port --value 6379 --type integer
docker-compose exec --user www-data nextcloud php occ config:system:set memcache.local --value '\OC\Memcache\Redis'
docker-compose exec --user www-data nextcloud php occ config:system:set memcache.locking --value '\OC\Memcache\Redis'
# docker-compose exec --user www-data nextcloud php occ config:system:set redis timeout --value 0.0 --type float
# docker-compose exec --user www-data nextcloud php occ config:system:set redis password --value ''
# docker-compose exec --user www-data nextcloud php occ config:system:set redis dbindex --value 0 --type integer
