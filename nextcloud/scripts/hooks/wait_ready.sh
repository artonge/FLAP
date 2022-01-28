#!/bin/bash

set -euo pipefail

until docker-compose logs nextcloud | grep --quiet "NOTICE: ready to handle connections"
do
    debug "Nextcloud is unavailable - sleeping"
    sleep 1
done
