#!/bin/bash

set -euo pipefail


if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

echo "Creating Mailman user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql "${args[@]}" -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER mailman WITH ENCRYPTED PASSWORD '$MAILMAN_DB_PWD' CREATEDB;
	CREATE DATABASE mailman WITH OWNER mailman;
EOSQL
