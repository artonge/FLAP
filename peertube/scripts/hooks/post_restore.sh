#!/bin/bash

set -eu

docker-compose up --detach postgres
flapctl hooks wait_ready postgres

docker exec --user postgres flap_postgres psql --command "DROP DATABASE peertube;"
docker exec --user postgres flap_postgres createdb -O peertube -E UTF8 -T template0 peertube

docker exec --user postgres flap_postgres psql -c "CREATE EXTENSION pg_trgm;" peertube
docker exec --user postgres flap_postgres psql -c "CREATE EXTENSION unaccent;" peertube

gzip --decompress --stdout "$FLAP_DATA/peertube/backup.sql.gz" | docker exec --interactive --user postgres flap_postgres psql --dbname peertube
