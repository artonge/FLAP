#!/bin/bash

set -euo pipefail


debug "Giving permission to sogo user to access file in /backup"
docker compose exec -T --user root sogo chown sogo:sogo /backup