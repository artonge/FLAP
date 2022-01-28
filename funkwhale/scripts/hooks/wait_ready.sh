#!/bin/bash

set -euo pipefail

until docker-compose logs funkwhale_api | grep "Application startup complete." > /dev/null
do
    debug "Funkwhale is unavailable - sleeping"
    sleep 1
done
