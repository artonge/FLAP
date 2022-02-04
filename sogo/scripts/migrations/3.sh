#!/bin/bash

set -euo pipefail


echo "* [3] Give correct right to sogo user on /backup directory."
docker-compose --no-ansi up --detach sogo
docker-compose exec -T --user root sogo chown sogo:sogo /backup
docker-compose --no-ansi down
