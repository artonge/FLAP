#!/bin/bash

set -eu

until docker-compose logs nextcloud | grep "NOTICE: ready to handle connections" > /dev/null
do
    debug "Nextcloud is unavailable - sleeping"
    sleep 1
done
