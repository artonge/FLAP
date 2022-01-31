#!/bin/bash

set -euo pipefail


FLAP_ENV_VARS="$FLAP_ENV_VARS \${SYNAPSE_DB_PWD} \${MATRIX_DOMAIN_NAME} \${JITSI_SERVER}"
SUBDOMAINS="$SUBDOMAINS matrix chat"
# 8448 - Matrix federation
NEEDED_PORTS="$NEEDED_PORTS 8448/tcp"

export SYNAPSE_DB_PWD
export JITSI_SERVER

SYNAPSE_DB_PWD=$(generatePassword matrix synapse_db_pwd)

# Use an external Jitsi domain the feature is enabled or if jitsi is not enabled.
if [ "${FLAG_SYNAPSE_USE_EXTERNAL_JITSI_SERVER:-}" == "true" ] || [[ "$FLAP_SERVICES" == *"jitsi"* ]]
then
	if [ ! -f "$FLAP_DATA/system/data/jitsi_server.txt" ]
	then
		echo "jitsi.demo.flap.cloud" > "$FLAP_DATA/system/data/jitsi_server.txt"
	fi

	JITSI_SERVER=$(cat "$FLAP_DATA/system/data/jitsi_server.txt")
else
	JITSI_SERVER="jitsi.$PRIMARY_DOMAIN_NAME"
fi
