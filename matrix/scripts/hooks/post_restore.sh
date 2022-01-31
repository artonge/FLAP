#!/bin/bash

set -euo pipefail


if [ "${FLAP_DEBUG:-}" != "true" ]
then
	args=(--quiet)
fi

docker-compose --ansi never up --detach postgres
flapctl hooks wait_ready postgres

docker exec --user postgres flap_postgres psql "${args[@]}" -c "DROP DATABASE synapse;"
docker exec --user postgres flap_postgres psql "${args[@]}" -c "CREATE DATABASE synapse ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' template=template0 OWNER synapse;"

# shellcheck disable=SC2002
gzip -dc "$FLAP_DATA/matrix/backup.sql.gz" | docker exec -i --user postgres flap_postgres psql "${args[@]}" -d synapse
