#!/bin/bash

set -eu

until docker-compose exec -T mariadb mysql --silent --password="$ADMIN_PWD" --execute "SHOW DATABASES" > /dev/null
do
    debug "MariaDB is unavailable - sleeping"
    sleep 1
done

sleep 1
