#!/bin/bash

set -eu

until docker-compose logs postgres | grep "database system is ready to accept connections"
do
    >&2 echo "PostgreSQL is unavailable - sleeping"
    sleep 1
done
