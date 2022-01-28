#!/bin/bash

set -euo pipefail

# Do not wait for synapse to be ready when it is not fully installed.
if [ ! -f "$FLAP_DATA/matrix/installed.txt" ]
then
	exit 0
fi

until docker-compose logs synapse | grep --quiet "Synapse now listening on TCP port 8008"
do
    debug "Synapse is unavailable - sleeping"
    sleep 1
done
