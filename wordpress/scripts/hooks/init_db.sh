#!/bin/bash

set -eu

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

debug "Creating Wordpress user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql "${args[@]}" -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER wordpress WITH ENCRYPTED PASSWORD '$WORDPRESS_DB_PWD' CREATEDB;
	CREATE DATABASE wordpress WITH OWNER wordpress;
EOSQL
