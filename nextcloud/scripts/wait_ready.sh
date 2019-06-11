#!/bin/bash

set -e

until docker-compose logs nextcloud | grep "NOTICE: ready to handle connections"
do
    >&2 echo "Nextcloud is unavailable - sleeping"
    sleep 1
done
