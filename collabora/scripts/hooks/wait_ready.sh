#!/bin/bash

set -eu

until docker-compose logs collabora | grep "Read to accept connections on port 9980." > /dev/null
do
    debug "Collabora is unavailable - sleeping"
done
