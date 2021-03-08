#!/bin/bash

set -eu

docker-compose --no-ansi up --detach nextcloud

flapctl hooks wait_ready nextcloud

echo "* [9] Enable Nextcloud app store."
docker exec --user www-data flap_nextcloud php occ config:system:set appstoreenabled --value true --type boolean

docker-compose --no-ansi down
