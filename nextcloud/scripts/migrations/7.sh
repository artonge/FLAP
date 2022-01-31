#!/bin/bash

set -euo pipefail

echo "* [7] Disable ransomware_detection plugin."
docker-compose --no-ansi up --detach nextcloud

flapctl hooks wait_ready nextcloud

docker exec --user www-data flap_nextcloud php occ config:system:set appstoreenabled --value true --type boolean

docker exec --user www-data flap_nextcloud php occ app:disable ransomware_detection

docker exec --user www-data flap_nextcloud php occ config:system:set appstoreenabled --value false --type boolean

docker-compose --no-ansi down
