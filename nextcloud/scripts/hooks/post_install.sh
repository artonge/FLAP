#!/bin/bash

set -eu

# Wait for nextcloud to be ready
$FLAP_DIR/nextcloud/scripts/wait_ready.sh

# Run post install script for nextcloud
docker-compose exec -T nextcloud chown www-data:www-data /data
docker-compose exec -T nextcloud touch /data/.ocdata

# Generate config.php with the config
docker-compose exec -T --user www-data nextcloud /generate_config.sh
