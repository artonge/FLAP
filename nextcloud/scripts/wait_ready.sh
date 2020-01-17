#!/bin/bash

set -eu

until docker-compose exec -T -u www-data nextcloud php occ status | grep "installed: true"
do
    >&2 echo "Nextcloud is unavailable - sleeping"
    sleep 1
done
