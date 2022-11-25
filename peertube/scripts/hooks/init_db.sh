#!/bin/bash

set -euo pipefail


if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

debug "Creating Peertube user and database in PostgreSQL."
docker compose exec -T --user postgres postgres psql "${args[@]}" -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER peertube WITH ENCRYPTED PASSWORD '$PEERTUBE_DB_PWD' CREATEDB;
EOSQL

docker compose exec -T --user postgres postgres createdb -O peertube -E UTF8 -T template0 peertube

debug "Creating extension."
docker compose exec -T --user postgres postgres psql "${args[@]}" -c "CREATE EXTENSION pg_trgm;" peertube
docker compose exec -T --user postgres postgres psql "${args[@]}" -c "CREATE EXTENSION unaccent;" peertube
