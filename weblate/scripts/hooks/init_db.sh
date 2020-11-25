#!/bin/bash

set -eu

echo "Creating Weblate user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER weblate WITH ENCRYPTED PASSWORD '$WEBLATE_DB_PWD' CREATEDB;
	CREATE DATABASE weblate WITH OWNER weblate;
EOSQL

echo "Creating extension."
docker-compose exec -T --user postgres postgres psql -c "CREATE EXTENSION pg_trgm;" weblate
