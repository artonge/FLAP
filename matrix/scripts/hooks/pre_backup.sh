#!/bin/bash

set -eu

docker exec --user postgres flap_postgres pg_dump synapse | gzip > "$FLAP_DATA/matrix/backup.sql.gz"
