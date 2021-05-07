#!/bin/bash

set -eu

debug "Generate domains specific config."
docker-compose exec -T --user www-data matomo /inner_scripts/generate_post_domain_update_config.sh
