#!/bin/bash

set -eu

docker-compose up --detach postgres
flapctl hooks wait_ready postgres

docker exec --user postgres flap_postgres psql --command "DROP DATABASE mailman;"
docker exec --user postgres flap_postgres createdb -O mailman -E UTF8 -T template0 mailman

docker exec --user postgres flap_postgres psql -c "CREATE EXTENSION pg_trgm;" mailman
docker exec --user postgres flap_postgres psql -c "CREATE EXTENSION unaccent;" mailman

gzip --decompress --stdout "$FLAP_DATA/mailman/backup.sql.gz" | docker exec --interactive --user postgres flap_postgres psql --dbname mailman
