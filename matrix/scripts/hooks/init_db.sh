#!/bin/bash

set -eu

echo "Creating Synapse user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER synapse WITH ENCRYPTED PASSWORD '$SYNAPSE_DB_PWD' CREATEDB;
	CREATE DATABASE synapse ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' template=template0 OWNER synapse;
EOSQL
