#!/bin/bash

set -eu

FLAP_ENV_VARS="$FLAP_ENV_VARS \${FUNKWHALE_DB_PWD} \${FUNKWHALE_DOMAIN_NAME} \${FUNKWHALE_DJANGO_SECRET_KEY}"
SUBDOMAINS="$SUBDOMAINS music"

export FUNKWHALE_DB_PWD
export FUNKWHALE_DJANGO_SECRET_KEY

FUNKWHALE_DB_PWD=$(generatePassword funkwhale funkwhale_db_pwd)
FUNKWHALE_DJANGO_SECRET_KEY=$(generatePassword funkwhale funkwhale_django_secret_key)
