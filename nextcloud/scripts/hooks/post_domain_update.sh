#!/bin/bash

set -e

# Wait for nextcloud to be ready
$FLAP_DIR/nextcloud/scripts/wait_ready.sh

# Generate config.php with the new config
docker-compose -T exec --user www-data nextcloud /generate_config.sh
