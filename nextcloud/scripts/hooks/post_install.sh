#!/bin/bash

set -e

# Wait for nextcloud to be ready
$FLAP_DIR/nextcloud/scripts/wait_ready.sh

# Run post install script for nextcloud
docker-compose exec nextcloud chown www-data:www-data /data
docker-compose exec nextcloud touch /data/.ocdata

# Generate config.php with the config
docker-compose exec --user www-data nextcloud /generate_config.sh