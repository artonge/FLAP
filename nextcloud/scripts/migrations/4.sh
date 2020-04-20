#!/bin/bash

set -eu

echo "* [4] Update user_saml and previewgenerator app."

docker-compose --no-ansi up --detach nextcloud

"$FLAP_DIR/nextcloud/scripts/wait_ready.sh"

php occ config:system:set appstoreenabled --value true --type boolean

php occ app:update previewgenerator
php occ app:enable previewgenerator

php occ app:update user_saml
php occ app:enable user_saml

php occ config:system:set appstoreenabled --value false --type boolean

docker-compose --no-ansi down
