#!/bin/bash

set -eu

FLAP_ENV_VARS="$FLAP_ENV_VARS \${WORDPRESS_DB_PWD}"
SUBDOMAINS="$SUBDOMAINS blog"

export WORDPRESS_DB_PWD

WORDPRESS_DB_PWD=$(generatePassword nextcloud wordpress_db_pwd)
