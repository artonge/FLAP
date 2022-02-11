#!/bin/bash

set -euo pipefail

docker-compose exec -T ldap slapcat | gzip > "$FLAP_DATA/ldap/backup.ldif.gz"
