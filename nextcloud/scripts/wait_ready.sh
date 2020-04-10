#!/bin/bash

set -eu

until docker-compose logs nextcloud | grep "NOTICE: ready to handle connections" > /dev/null
do
    echo "Nextcloud is unavailable - sleeping"
    sleep 1
done
