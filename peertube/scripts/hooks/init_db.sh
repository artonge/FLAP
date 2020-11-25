#!/bin/bash

set -eu

echo "Creating Peertube user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER peertube WITH ENCRYPTED PASSWORD '$PEERTUBE_DB_PWD' CREATEDB;
EOSQL

docker-compose exec -T --user postgres postgres createdb -O peertube -E UTF8 -T template0 peertube

echo "Creating extension."
docker-compose exec -T --user postgres postgres psql -c "CREATE EXTENSION pg_trgm;" peertube
docker-compose exec -T --user postgres postgres psql -c "CREATE EXTENSION unaccent;" peertube
