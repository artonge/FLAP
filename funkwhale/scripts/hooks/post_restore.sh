#!/bin/bash

set -euo pipefail


if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

docker-compose up --detach postgres
flapctl hooks wait_ready postgres

docker exec --user postgres flap_postgres psql "${args[@]}" --command "DROP DATABASE funkwhale;"
docker exec --user postgres flap_postgres createdb -O funkwhale -E UTF8 -T template0 funkwhale

docker exec --user postgres flap_postgres psql "${args[@]}" -c "CREATE EXTENSION pg_trgm;" funkwhale
docker exec --user postgres flap_postgres psql "${args[@]}" -c "CREATE EXTENSION unaccent;" funkwhale

gzip --decompress --stdout "$FLAP_DATA/funkwhale/backup.sql.gz" | docker exec --interactive --user postgres flap_postgres psql "${args[@]}" --dbname funkwhale
