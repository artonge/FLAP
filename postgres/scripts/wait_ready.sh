#!/bin/bash

set -eu

until docker-compose logs postgres | grep "database system is ready to accept connections" > /dev/null
do
    echo "PostgreSQL is unavailable - sleeping"
    sleep 1
done
