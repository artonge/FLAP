#!/bin/bash

set -eu

until docker-compose logs mail | grep "daemon started" > /dev/null
do
    echo "Mail is unavailable - sleeping"
    sleep 1
done
