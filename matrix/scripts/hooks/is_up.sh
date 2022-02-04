#!/bin/bash

set -euo pipefail

# Fake true when synapse is not fully installed.
if [ ! -f "$FLAP_DATA/matrix/installed.txt" ]
then
	exit 0
fi

docker-compose logs synapse | grep --quiet "Synapse now listening on TCP port 8008"
