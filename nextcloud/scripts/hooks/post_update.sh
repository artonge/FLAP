#!/bin/bash

set -eu

# Wait for nextcloud to be ready.
"$FLAP_DIR/nextcloud/scripts/wait_ready.sh"

# Generate config.php with the config.
docker-compose exec -T --user www-data nextcloud php occ upgrade
docker-compose exec -T --user www-data nextcloud php occ maintenance:mode --off
