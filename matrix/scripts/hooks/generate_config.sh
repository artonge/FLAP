#!/bin/bash

set -eu

# Add matrix's nginx config to the nginx config folder.
# This is needed because synapse can not be multi-domains.
# So we have to choose a MATRIX_DOMAIN_NAME that will always be the same,
# and generate a nginx config file for that domain only.
debug "Generating Synapse's Nginx configuration."
# shellcheck disable=SC2016
envsubst "$FLAP_ENV_VARS" < "$FLAP_DIR/matrix/config/nginx.conf" > "$FLAP_DIR/nginx/config/conf.d/domains/$MATRIX_DOMAIN_NAME/synapse.conf"

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
