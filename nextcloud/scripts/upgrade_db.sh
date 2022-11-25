#!/bin/bash

set -euo pipefail


docker compose exec --user www-data nextcloud php occ db:add-missing-columns
docker compose exec --user www-data nextcloud php occ db:add-missing-indices
docker compose exec --user www-data nextcloud php occ db:add-missing-primary-keys
docker compose exec --user www-data nextcloud php occ db:convert-filecache-bigint --no-interaction

