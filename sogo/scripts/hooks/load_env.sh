#!/bin/bash

set -euo pipefail


FLAP_ENV_VARS="$FLAP_ENV_VARS \${SOGO_DB_PWD}"
SUBDOMAINS="$SUBDOMAINS mail"

export SOGO_DB_PWD
SOGO_DB_PWD=$(generatePassword sogo sogo_db_pwd)
