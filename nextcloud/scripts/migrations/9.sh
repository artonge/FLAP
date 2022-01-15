#!/bin/bash

set -euo pipefail

# v1.14.7

docker-compose --no-ansi up --detach nextcloud

flapctl hooks wait_ready nextcloud

echo "* [9] Enable Nextcloud app store."
docker exec --user www-data flap_nextcloud php occ config:system:set appstoreenabled --value true --type boolean

echo "* [9] Update Nextcloud's plugins."
docker exec --user www-data flap_nextcloud php occ app:update --all
docker exec --user www-data flap_nextcloud php occ app:enable user_saml

docker-compose --no-ansi down
