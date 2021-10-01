#!/bin/bash

set -eu

docker-compose up --detach postgres
flapctl hooks wait_ready postgres

if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

docker exec --user postgres flap_postgres psql "${args[@]}" --command "DROP DATABASE wordpress;"
docker exec --user postgres flap_postgres psql "${args[@]}" --command "CREATE DATABASE wordpress WITH OWNER wordpress;"

gzip --decompress --stdout "$FLAP_DATA/wordpress/backup.sql.gz" | docker exec --interactive --user postgres flap_postgres psql "${args[@]}" --dbname wordpress

docker-compose up --detach wordpress
flapctl hooks wait_ready wordpress

docker exec --user www-data flap_wordpress php occ maintenance:data-fingerprint
