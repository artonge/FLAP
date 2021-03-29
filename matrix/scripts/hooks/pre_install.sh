#!/bin/bash

set -eu

echo "Generating Synapse's homserver.yaml configuration file."
docker-compose run -T --rm --no-deps synapse generate

flapctl hooks generate_config matrix
