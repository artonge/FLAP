#!/bin/bash

set -euo pipefail


docker-compose up --detach mariadb
flapctl hooks wait_ready mariadb

docker exec flap_mariadb mysql --password="$ADMIN_PWD" --execute="DROP DATABASE matomo;"
docker exec flap_mariadb mysql --password="$ADMIN_PWD" --execute="CREATE DATABASE matomo;"
docker exec flap_mariadb mysql --password="$ADMIN_PWD" --execute="GRANT ALL PRIVILEGES ON matomo.* TO matomo identified by '$MATOMO_DB_PWD';"

# shellcheck disable=SC2002
gzip --decompress --stdout "$FLAP_DATA/matomo/backup.sql.gz" | docker exec --interactive flap_mariadb mysql --password="$ADMIN_PWD" --database matomo

docker-compose up --detach matomo
flapctl hooks wait_ready matomo
