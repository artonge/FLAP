#!/bin/bash

set -euo pipefail

# v1.23.0

echo "* [4] Backuping users."
flapctl start ldap
docker-compose exec -T ldap slapcat | gzip > "$FLAP_DATA/ldap/backup.ldif.gz"
flapctl stop ldap

flapctl hooks post_restore ldap
