#!/bin/bash

set -euo pipefail


FLAP_ENV_VARS="$FLAP_ENV_VARS \${ADMIN_PWD}"
# 22 - SSH
NEEDED_PORTS="$NEEDED_PORTS 22/tcp"

export ADMIN_PWD
ADMIN_PWD=$(generatePassword system admin_pwd)
