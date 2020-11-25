#!/bin/bash

set -eu

docker exec flap_mariadb mysqldump --user matomo --password="$MATOMO_DB_PWD" matomo | gzip > "$FLAP_DATA/matomo/backup.sql.gz"
