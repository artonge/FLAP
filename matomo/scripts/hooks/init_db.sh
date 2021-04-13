#!/bin/bash

set -eu

debug "Creating Matomo user and database in MariaDB."
docker-compose exec -T mariadb mysql --silent --password="$ADMIN_PWD" <<-EOSQL
	CREATE DATABASE matomo;
	GRANT ALL PRIVILEGES ON matomo.* TO matomo identified by '$MATOMO_DB_PWD';
EOSQL
