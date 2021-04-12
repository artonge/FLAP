#!/bin/bash

set -eu

if [ -f "$FLAP_DATA/matrix/synapse/data/homeserver.yaml" ]
then
	synapse_final_config="$FLAP_DATA/matrix/synapse/data/homeserver.yaml"
	config_files=("$synapse_final_config" "$FLAP_DIR/matrix/config/synapse.yaml")

	debug "Merging synapse.yaml with homeserver.yaml."
	# shellcheck disable=SC2016
	yq \
		--yaml-output \
		--yaml-roundtrip \
		--slurp \
		'reduce .[] as $config ({}; . * $config)' "${config_files[@]}" \
		 > "$synapse_final_config".tmp

	mv "$synapse_final_config".tmp "$synapse_final_config"
fi
