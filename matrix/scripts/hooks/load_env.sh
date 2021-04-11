#!/bin/bash

set -eu

FLAP_ENV_VARS="$FLAP_ENV_VARS \${SYNAPSE_DB_PWD} \${MATRIX_DOMAIN_NAME} \${JITSI_SERVER}"
SUBDOMAINS="$SUBDOMAINS matrix chat"
# 8448 - Matrix federation
NEEDED_PORTS="$NEEDED_PORTS 8448/tcp"

export SYNAPSE_DB_PWD
export MATRIX_DOMAIN_NAME
export JITSI_SERVER

SYNAPSE_DB_PWD=$(generatePassword matrix synapse_db_pwd)

# Set the matrix domain if primary domain is set.
touch "$FLAP_DATA/matrix/domain.txt"
MATRIX_DOMAIN_NAME=$(cat "$FLAP_DATA/matrix/domain.txt")
if [ "$MATRIX_DOMAIN_NAME" == "" ] && [ "$PRIMARY_DOMAIN_NAME" != "" ]
then
	MATRIX_DOMAIN_NAME=$PRIMARY_DOMAIN_NAME
	echo "$MATRIX_DOMAIN_NAME" > "$FLAP_DATA/matrix/domain.txt"
fi

JITSI_SERVER="jitsi.$PRIMARY_DOMAIN_NAME"
# Use an external Jitsi domain the feature is enabled.
if [ "${FLAG_SYNAPSE_USE_EXTERNAL_JITSI_SERVER:-}" == "true" ]
then
	if [ ! -f "$FLAP_DATA/system/data/jitsi_server.txt" ]
	then
		echo "jitsi.demo.flap.cloud" > "$FLAP_DATA/system/data/jitsi_server.txt"
	fi

	JITSI_SERVER=$(cat "$FLAP_DATA/system/data/jitsi_server.txt")
fi
