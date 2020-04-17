#!/bin/bash

set -eu

FLAP_ENV_VARS="$FLAP_ENV_VARS \${NEXTCLOUD_DB_PWD}"
SUBDOMAINS="$SUBDOMAINS files"

export NEXTCLOUD_DB_PWD

NEXTCLOUD_DB_PWD=$(generatePassword nextcloud nextcloud_db_pwd)
