#!/bin/bash

set -eu

docker exec --user postgres flap_postgres pg_dump peertube | gzip > "$FLAP_DATA/peertube/backup.sql.gz"
