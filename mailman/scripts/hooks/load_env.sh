#!/bin/bash

set -euo pipefail


FLAP_ENV_VARS="$FLAP_ENV_VARS \${MAILMAN_DB_PWD} \${MAILMAN_DJANGO_SECRET_KEY} \${MAILMAN_HYPERKITTY_API_KEY}"
SUBDOMAINS="$SUBDOMAINS lists"

export MAILMAN_DB_PWD
export MAILMAN_DJANGO_SECRET_KEY
export MAILMAN_HYPERKITTY_API_KEY

MAILMAN_DB_PWD=$(generatePassword mailman mailman_db_pwd)
MAILMAN_DJANGO_SECRET_KEY=$(generatePassword mailman mailman_django_secret_key)
MAILMAN_HYPERKITTY_API_KEY=$(generatePassword mailman mailman_hyperkitty_secret_key)
