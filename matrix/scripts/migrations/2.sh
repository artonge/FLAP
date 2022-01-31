#!/bin/bash

set -euo pipefail

echo "* [2] Remove port from the TURN_SERVER URI."
echo "demo.flap.cloud" > "$FLAP_DATA/system/data/turn_server.txt"

echo "* [2] Generate config templates to have an updated synapse.yml config file."
flapctl config generate_templates

echo "* [2] Update TURN servers URIs in homeserver.yml."
"$FLAP_DIR/system/cli/lib/merge_yaml.sh" \
	"$FLAP_DATA/matrix/synapse/data/homeserver.yaml" \
	"$FLAP_DIR/matrix/config/synapse.yaml"
