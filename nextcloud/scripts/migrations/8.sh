#!/bin/bash

set -eu

docker-compose --no-ansi up --detach nextcloud

flapctl hooks wait_ready nextcloud

docker exec --user www-data flap_nextcloud php occ config:system:set appstoreenabled --value true --type boolean

echo "* [8] Disable dashboard plugin."
docker exec --user www-data flap_nextcloud php occ app:disable dashboard

echo "* [8] Update disabled apps and reenable them."
docker exec --user www-data flap_nextcloud php occ app:update --all
docker exec --user www-data flap_nextcloud php occ app:enable user_saml
docker exec --user www-data flap_nextcloud php occ app:enable previewgenerator
docker exec --user www-data flap_nextcloud php occ app:enable ransomware_protection

docker exec --user www-data flap_nextcloud php occ config:system:set appstoreenabled --value false --type boolean

docker-compose --no-ansi down
