#!/bin/bash

set -eu

until docker-compose logs mail | grep "daemon started" > /dev/null
do
    debug "Mail is unavailable - sleeping"
    sleep 1
done
