#!/bin/bash

set -euo pipefail

# Version 1.14.6

echo "* [4] Update homeserver.yml to remove templates"
synapse_final_config="$FLAP_DATA/matrix/synapse/data/homeserver.yaml"
config_files=("$synapse_final_config" "$FLAP_DIR/matrix/config/synapse.yaml")

echo "Merging synapse.yaml with homeserver.yaml."
# shellcheck disable=SC2016
yq \
	--yaml-output \
	--yaml-roundtrip \
	--slurp \
	'reduce .[] as $config ({}; . * $config)' "${config_files[@]}" \
		> "$synapse_final_config".tmp

mv "$synapse_final_config".tmp "$synapse_final_config"