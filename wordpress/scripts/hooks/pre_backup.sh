#!/bin/bash

set -eu

docker exec --user postgres flap_postgres pg_dump wordpress | gzip > "$FLAP_DATA/wordpress/backup.sql.gz"
