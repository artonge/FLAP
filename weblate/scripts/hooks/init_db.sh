#!/bin/bash

set -eu

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

debug "Creating Weblate user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql "${args[@]}" -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER weblate WITH ENCRYPTED PASSWORD '$WEBLATE_DB_PWD' CREATEDB;
	CREATE DATABASE weblate WITH OWNER weblate;
EOSQL

debug "Creating extension."
docker-compose exec -T --user postgres postgres psql "${args[@]}" -c "CREATE EXTENSION pg_trgm;" weblate
