#!/bin/bash

set -e

# Wait for nextcloud to be ready
./scripts/wait_ready.sh

# Generate config.php with the new config
docker-compose exec --user www-data nextcloud /generate_config.sh
