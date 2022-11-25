#!/bin/bash

set -euo pipefail


docker compose exec -T mariadb mysql --silent --password="$ADMIN_PWD" --execute "SHOW DATABASES" > /dev/null
# 1 second of sleep to let mariadb fully start.
sleep 1
