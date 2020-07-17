#!/bin/bash

set -eu

FLAP_ENV_VARS="$FLAP_ENV_VARS \${ADMIN_PWD} \${ARCH} \${FLAP_VERSION}"
# 22 - SSH
NEEDED_PORTS="$NEEDED_PORTS 22/tcp"

export ADMIN_PWD
ADMIN_PWD=$(generatePassword system admin_pwd)

export ARCH
ARCH=$(uname -m)

cd "$FLAP_DIR"
export FLAP_VERSION
FLAP_VERSION=$(git describe --tags --abbrev=0)
