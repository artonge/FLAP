#!/bin/bash

set -euo pipefail


FLAP_ENV_VARS="$FLAP_ENV_VARS \${ENABLE_MONITORING}"
SUBDOMAINS="$SUBDOMAINS monitoring"
