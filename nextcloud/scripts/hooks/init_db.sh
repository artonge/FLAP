#!/bin/bash

set -eu

debug "Creating Nextcloud user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER nextcloud WITH ENCRYPTED PASSWORD '$NEXTCLOUD_DB_PWD' CREATEDB;
	CREATE DATABASE nextcloud WITH OWNER nextcloud;
EOSQL
