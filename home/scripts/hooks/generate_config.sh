#!/bin/bash

set -euo pipefail

debug "Merge variables.yml files"
mapfile -t variables_type_files < <(find "$FLAP_DIR" -maxdepth 2 -name variables.yml)

# shellcheck disable=SC2016
yq --slurp 'reduce .[] as $variables ({}; . * $variables)' "${variables_type_files[@]}" > "$FLAP_DATA/system/variables.json"
