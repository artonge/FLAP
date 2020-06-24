#!/bin/bash

set -eu

docker-compose --no-ansi up --detach postgres
flapctl hooks wait_ready postgres

docker exec --user postgres flap_postgres psql --dbname template1 --command "DROP DATABASE nextcloud;"
docker exec --user postgres flap_postgres psql --dbname template1 --command "CREATE DATABASE nextcloud WITH OWNER nextcloud;"

# shellcheck disable=SC2002
gzip --decompress --stdout "$FLAP_DATA/nextcloud/backup.sql.gz" | docker exec --interactive --user postgres flap_postgres psql --dbname nextcloud

docker-compose --no-ansi up --detach nextcloud
flapctl hooks wait_ready nextcloud

docker exec --user www-data flap_nextcloud php occ maintenance:data-fingerprint
