#!/bin/bash

set -eu

docker-compose up --detach postgres
flapctl hooks wait_ready postgres

docker exec --user postgres flap_postgres psql --command "DROP DATABASE funkwhale;"
docker exec --user postgres flap_postgres createdb -O funkwhale -E UTF8 -T template0 funkwhale

docker exec --user postgres flap_postgres psql -c "CREATE EXTENSION pg_trgm;" funkwhale
docker exec --user postgres flap_postgres psql -c "CREATE EXTENSION unaccent;" funkwhale

gzip --decompress --stdout "$FLAP_DATA/funkwhale/backup.sql.gz" | docker exec --interactive --user postgres flap_postgres psql --dbname funkwhale
