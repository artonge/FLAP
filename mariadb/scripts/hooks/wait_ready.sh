#!/bin/bash

set -eu

until docker-compose exec -T mariadb mysql --password="$ADMIN_PWD" --execute "SHOW DATABASES" > /dev/null
do
    echo "MariaDB is unavailable - sleeping"
    sleep 1
done

sleep 1
