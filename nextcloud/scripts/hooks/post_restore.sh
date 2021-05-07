#!/bin/bash

set -eu

docker-compose up --detach postgres
flapctl hooks wait_ready postgres

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

docker exec --user postgres flap_postgres psql "${args[@]}" --command "DROP DATABASE nextcloud;"
docker exec --user postgres flap_postgres psql "${args[@]}" --command "CREATE DATABASE nextcloud WITH OWNER nextcloud;"

gzip --decompress --stdout "$FLAP_DATA/nextcloud/backup.sql.gz" | docker exec --interactive --user postgres flap_postgres psql "${args[@]}" --dbname nextcloud

docker-compose up --detach nextcloud
flapctl hooks wait_ready nextcloud

docker exec --user www-data flap_nextcloud php occ maintenance:data-fingerprint
