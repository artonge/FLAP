#!/bin/bash

set -euo pipefail

echo "* [4] Update user_saml and previewgenerator app."

docker-compose --no-ansi up --detach nextcloud

flapctl hooks wait_ready nextcloud

docker exec --user www-data flap_nextcloud php occ config:system:set appstoreenabled --value true --type boolean

docker exec --user www-data flap_nextcloud php occ app:update previewgenerator
docker exec --user www-data flap_nextcloud php occ app:enable previewgenerator

docker exec --user www-data flap_nextcloud php occ app:update user_saml
docker exec --user www-data flap_nextcloud php occ app:enable user_saml

docker exec --user www-data flap_nextcloud php occ config:system:set appstoreenabled --value false --type boolean

docker-compose --no-ansi down
