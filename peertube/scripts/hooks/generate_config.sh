#!/bin/bash

set -eu

# Add peertube's nginx config to the nginx config folder.
# This is needed because synapse can not be multi-domains.
# So we have to choose a PEERTUBE_DOMAIN_NAME that will always be the same,
# and generate a nginx config file for that domain only.
debug "Generating Peertube's Nginx configuration."
# shellcheck disable=SC2016
envsubst "$FLAP_ENV_VARS" < "$FLAP_DIR/peertube/config/nginx.conf" > "$FLAP_DIR/nginx/config/conf.d/domains/$PEERTUBE_DOMAIN_NAME/peertube.conf"
