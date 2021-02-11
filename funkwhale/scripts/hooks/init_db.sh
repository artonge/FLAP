#!/bin/bash

set -eu

echo "Creating Funkwhale user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER funkwhale WITH ENCRYPTED PASSWORD '$FUNKWHALE_DB_PWD' CREATEDB;
EOSQL

docker-compose exec -T --user postgres postgres createdb -O funkwhale -E UTF8 -T template0 funkwhale

echo "Creating extension."
docker-compose exec -T --user postgres postgres psql -c "CREATE EXTENSION citext;" funkwhale
docker-compose exec -T --user postgres postgres psql -c "CREATE EXTENSION unaccent;" funkwhale

echo "Run initials migrations."
docker-compose run --rm funkwhale_api python manage.py migrate
