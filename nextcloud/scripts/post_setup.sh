#!/bin/bash

set -e

until docker-compose logs nextcloud | grep "NOTICE: ready to handle connections"
do
    >&2 echo "Nextcloud is unavailable - sleeping"
    sleep 1
done

# Run post install script for nextcloud
docker-compose exec nextcloud chown www-data:www-data /data
docker-compose exec nextcloud touch /data/.ocdata
docker-compose exec --user www-data nextcloud /setup.sh
