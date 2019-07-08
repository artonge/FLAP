#!/bin/bash

set -eu

# Wait for nextcloud to be ready
$FLAP_DIR/nextcloud/scripts/wait_ready.sh

# Generate config.php with the new config
docker-compose exec -T --user www-data nextcloud /generate_config.sh
