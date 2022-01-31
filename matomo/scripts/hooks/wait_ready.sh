#!/bin/bash

set -euo pipefail

until docker-compose logs matomo | grep --quiet "NOTICE: ready to handle connections"
do
    debug "Matomo is unavailable - sleeping"
    sleep 1
done
