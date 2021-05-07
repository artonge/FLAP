#!/bin/bash

set -eu

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--silent)
fi

debug "Creating Matomo user and database in MariaDB."
docker-compose exec -T mariadb mysql "${args[@]}" --password="$ADMIN_PWD" <<-EOSQL
	CREATE DATABASE matomo;
	GRANT ALL PRIVILEGES ON matomo.* TO matomo identified by '$MATOMO_DB_PWD';
EOSQL
