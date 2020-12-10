#!/bin/bash

set -eu

# Version v1.14.2

echo "* [1] Migrate database to utf8mb4"
docker-compose run --rm --user www-data matomo php /var/www/html/console config:set core:convert-to-utf8mb4
