#!/bin/bash

set -eu

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

debug "Creating Funkwhale user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql "${args[@]}" -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER funkwhale WITH ENCRYPTED PASSWORD '$FUNKWHALE_DB_PWD' CREATEDB;
EOSQL

docker-compose exec -T --user postgres postgres createdb -O funkwhale -E UTF8 -T template0 funkwhale

debug "Creating extension."
docker-compose exec -T --user postgres postgres psql "${args[@]}" -c "CREATE EXTENSION citext;" funkwhale
docker-compose exec -T --user postgres postgres psql "${args[@]}" -c "CREATE EXTENSION unaccent;" funkwhale

debug "Run initials migrations."
if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(-v 0)
fi

docker-compose run --rm funkwhale_api python manage.py migrate "${args[@]}"
