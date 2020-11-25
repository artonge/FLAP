#!/bin/bash

set -eu

until docker-compose logs peertube | grep "Server listening on 0.0.0.0:9000" > /dev/null
do
    echo "Peertube is unavailable - sleeping"
    sleep 1
done
