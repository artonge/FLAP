#!/bin/bash

set -eu

echo "Creating Mailman user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER mailman WITH ENCRYPTED PASSWORD '$MAILMAN_DB_PWD' CREATEDB;
	CREATE DATABASE mailman WITH OWNER mailman;
EOSQL
