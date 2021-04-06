#!/bin/bash

set -eu

docker exec --user postgres flap_postgres pg_dump mailman | gzip > "$FLAP_DATA/mailman/backup.sql.gz"
