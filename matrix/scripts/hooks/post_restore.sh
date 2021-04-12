#!/bin/bash

set -eu

docker-compose --ansi never up --detach postgres
flapctl hooks wait_ready postgres

docker exec --user postgres flap_postgres psql -c "DROP DATABASE synapse;"
docker exec --user postgres flap_postgres psql -c "CREATE DATABASE synapse ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' template=template0 OWNER synapse;"

# shellcheck disable=SC2002
gzip -dc "$FLAP_DATA/matrix/backup.sql.gz" | docker exec -i --user postgres flap_postgres psql -d synapse
