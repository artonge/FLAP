#!/bin/bash

set -eu

docker exec --user postgres flap_postgres pg_dump funkwhale | gzip > "$FLAP_DATA/funkwhale/backup.sql.gz"
