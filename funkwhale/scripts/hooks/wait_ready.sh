#!/bin/bash

set -eu

until docker-compose logs funkwhale | grep "Server listening on 0.0.0.0:5000" > /dev/null
do
    echo "Funkwhale is unavailable - sleeping"
    sleep 1
done
