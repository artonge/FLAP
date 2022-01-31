#!/bin/bash

set -euo pipefail

echo "* [1] Update homeserver.yml to disable sso whitelist"
"$FLAP_DIR/system/cli/lib/merge_yaml.sh" \
	"$FLAP_DATA/matrix/synapse/data/homeserver.yaml" \
	"$FLAP_DIR/matrix/config/synapse.yaml"
