#!/bin/bash

set -euo pipefail


FLAP_ENV_VARS="$FLAP_ENV_VARS \${MATOMO_DB_PWD}"
SUBDOMAINS="$SUBDOMAINS analytics"

export MATOMO_DB_PWD

MATOMO_DB_PWD=$(generatePassword matomo matomo_db_pwd)
