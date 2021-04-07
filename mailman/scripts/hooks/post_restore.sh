#!/bin/bash

set -eu

docker-compose up --detach postgres
flapctl hooks wait_ready postgres

docker exec --user postgres flap_postgres psql --command "DROP DATABASE mailman;"
docker exec --user postgres flap_postgres psql --command "CREATE DATABASE mailman WITH OWNER mailman;"

gzip --decompress --stdout "$FLAP_DATA/mailman/backup.sql.gz" | docker exec --interactive --user postgres flap_postgres psql --dbname mailman

docker-compose up --detach mailman
flapctl hooks wait_ready mailman
