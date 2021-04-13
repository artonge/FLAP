#!/bin/bash

set -eu

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

debug "Creating Nextcloud user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql "${args[@]}" -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER nextcloud WITH ENCRYPTED PASSWORD '$NEXTCLOUD_DB_PWD' CREATEDB;
	CREATE DATABASE nextcloud WITH OWNER nextcloud;
EOSQL
