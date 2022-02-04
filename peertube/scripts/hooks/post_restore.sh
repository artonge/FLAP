#!/bin/bash

set -euo pipefail


docker-compose up --detach postgres
flapctl wait_ready postgres

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

docker exec --user postgres flap_postgres psql "${args[@]}" --command "DROP DATABASE peertube;"
docker exec --user postgres flap_postgres createdb -O peertube -E UTF8 -T template0 peertube

docker exec --user postgres flap_postgres psql "${args[@]}" -c "CREATE EXTENSION pg_trgm;" peertube
docker exec --user postgres flap_postgres psql "${args[@]}" -c "CREATE EXTENSION unaccent;" peertube

gzip --decompress --stdout "$FLAP_DATA/peertube/backup.sql.gz" | docker exec --interactive --user postgres flap_postgres psql "${args[@]}" --dbname peertube
