#!/bin/bash

set -eu

FLAP_ENV_VARS="$FLAP_ENV_VARS \${MATOMO_DB_PWD} \${ENABLE_MATOMO}"
SUBDOMAINS="$SUBDOMAINS analytics"

export ENABLE_MATOMO
export MATOMO_DB_PWD

ENABLE_MATOMO=${ENABLE_MATOMO:-false}

MATOMO_DB_PWD=$(generatePassword matomo matomo_db_pwd)
