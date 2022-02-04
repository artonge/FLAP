#!/bin/bash

set -euo pipefail

# Fake true when synapse is not fully installed.
if [ ! -f "$FLAP_DATA/matrix/installed.txt" ]
then
	exit 0
fi

docker-compose exec -T synapse curl -fSs http://localhost:8008/health
