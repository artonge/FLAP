#!/bin/bash

set -eu

# Do not wait for synapse to be ready when it is not fully installed.
if [ ! -f "$FLAP_DATA/matrix/installed.txt" ]
then
	exit 0
fi

until docker-compose logs synapse | grep "Synapse now listening on TCP port 8008" > /dev/null
do
    debug "Synapse is unavailable - sleeping"
    sleep 1
done
