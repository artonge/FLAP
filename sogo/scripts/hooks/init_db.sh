#!/bin/bash

set -euo pipefail


if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

debug "Creating SOGo user and database in PostgreSQL."
docker compose exec -T --user postgres postgres psql "${args[@]}" -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER sogo WITH ENCRYPTED PASSWORD '$SOGO_DB_PWD' CREATEDB;
	CREATE DATABASE sogo WITH OWNER sogo;
EOSQL
