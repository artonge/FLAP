#!/bin/bash

set -eu

i=1
until docker-compose logs collabora | grep "Read to accept connections on port 9980." > /dev/null
do
    (( i++ ))
    if [ "$i" == "50" ]
    then
        docker-compose logs collabora
        exit 1
    fi

    debug "Collabora is unavailable - sleeping"
    sleep 2
done
