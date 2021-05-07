#!/bin/bash

set -eu

docker-compose exec --user www-data nextcloud php occ db:add-missing-columns
docker-compose exec --user www-data nextcloud php occ db:add-missing-indices
