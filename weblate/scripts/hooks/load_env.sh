#!/bin/bash

set -euo pipefail


# shellcheck disable=SC2016
FLAP_ENV_VARS="$FLAP_ENV_VARS \${WEBLATE_DB_PWD}"
SUBDOMAINS="$SUBDOMAINS weblate"

export WEBLATE_DB_PWD
WEBLATE_DB_PWD=$(generatePassword weblate weblate_db_pwd)
