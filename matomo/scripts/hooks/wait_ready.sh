#!/bin/bash

set -eu

until docker-compose logs matomo | grep "NOTICE: ready to handle connections" > /dev/null
do
    debug "Matomo is unavailable - sleeping"
    sleep 1
done
