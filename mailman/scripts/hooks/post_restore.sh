#!/bin/bash

set -euo pipefail


docker-compose up --detach postgres
flapctl wait_ready postgres

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

docker exec --user postgres flap_postgres psql "${args[@]}" --command "DROP DATABASE mailman;"
docker exec --user postgres flap_postgres psql "${args[@]}" --command "CREATE DATABASE mailman WITH OWNER mailman;"

gzip --decompress --stdout "$FLAP_DATA/mailman/backup.sql.gz" | docker exec --interactive --user postgres flap_postgres psql "${args[@]}" --dbname mailman
