#!/bin/bash

set -eu

echo "Giving permission to nextcloud user to access file in /data"
docker-compose exec -T nextcloud touch /data/.ocdata
docker-compose exec -T nextcloud chown www-data:www-data /data

echo "Generate config.php with the config."
docker-compose exec -T --user www-data nextcloud /inner_scripts/generate_initial_config.sh
