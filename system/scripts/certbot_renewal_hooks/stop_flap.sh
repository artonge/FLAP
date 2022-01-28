#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source /etc/environment

export FLAP_DIR
export FLAP_DATA

flapctl stop nginx
