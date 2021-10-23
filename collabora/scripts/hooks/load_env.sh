#!/bin/bash

set -eu

FLAP_ENV_VARS="$FLAP_ENV_VARS \${COLLABORA_EXTRA_PARAMS}"
SUBDOMAINS="$SUBDOMAINS office"

export COLLABORA_EXTRA_PARAMS

COLLABORA_EXTRA_PARAMS='--o:welcome.enable=false --o:ssl.enable=false --o:ssl.termination=true'
