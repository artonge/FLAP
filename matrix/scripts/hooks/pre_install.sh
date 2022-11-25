#!/bin/bash

set -euo pipefail


debug "Generating Synapse's homeserver.yaml configuration file."
docker compose run -T --rm --no-deps synapse generate

flapctl hooks generate_config matrix

generate_saml_keys matrix
