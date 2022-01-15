#!/bin/bash

set -euo pipefail


echo "Listing nextcloud app."
docker exec --tty --user www-data flap_nextcloud php occ app:list --shipped=false

# Concider running the following commands to repaire potential nextcloud issues.
# php occ db:add-missing-indices
# php occ db:convert-filecache-bigint
# php occ maintenance:mimetype:update-js
# php occ maintenance:mimetype:update-db
# php occ maintenance:theme:update
# php occ maintenance:update:htaccess
# php occ maintenance:repair
# php occ maintenance:mode --off
