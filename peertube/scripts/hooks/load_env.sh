#!/bin/bash

set -eu

FLAP_ENV_VARS="$FLAP_ENV_VARS \${PEERTUBE_DB_PWD} \${PEERTUBE_DOMAIN_NAME} \${PEERTUBE_SAML_PLUGIN_VERSION}"
SUBDOMAINS="$SUBDOMAINS video"

# 1935 - Live streaming
NEEDED_PORTS="$NEEDED_PORTS 1935/tcp"

export ENABLE_PEERTUBE
export PEERTUBE_DOMAIN_NAME
export PEERTUBE_DB_PWD
export PEERTUBE_SAML_PLUGIN_VERSION

ENABLE_PEERTUBE=${ENABLE_PEERTUBE:-false}

PEERTUBE_DB_PWD=$(generatePassword peertube peertube_db_pwd)

# Set the peertube domain if primary domain is set.
touch "$FLAP_DATA/peertube/domain.txt"
PEERTUBE_DOMAIN_NAME=$(cat "$FLAP_DATA/peertube/domain.txt")
if [ "$PEERTUBE_DOMAIN_NAME" == "" ]
then
	PEERTUBE_DOMAIN_NAME=$PRIMARY_DOMAIN_NAME
	echo "$PEERTUBE_DOMAIN_NAME" > "$FLAP_DATA/peertube/domain.txt"
fi

PEERTUBE_SAML_PLUGIN_VERSION=0.0.4