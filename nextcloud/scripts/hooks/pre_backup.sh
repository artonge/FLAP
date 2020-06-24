#!/bin/bash

set -eu

docker exec --user www-data flap_nextcloud php occ maintenance:mode --on

docker exec --user postgres flap_postgres pg_dump nextcloud | gzip > "$FLAP_DATA/nextcloud/backup.sql.gz"

docker exec --user www-data flap_nextcloud php occ maintenance:mode --off
