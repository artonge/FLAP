#!/bin/bash

set -eu

# shellcheck disable=SC2016
FLAP_ENV_VARS="$FLAP_ENV_VARS \${JICOFO_COMPONENT_SECRET} \${JICOFO_AUTH_PASSWORD} \${JVB_AUTH_PASSWORD} \${TURN_SECRET} \${TURN_SERVER}"
SUBDOMAINS="$SUBDOMAINS coturn jitsi"

export JICOFO_COMPONENT_SECRET
export JICOFO_AUTH_PASSWORD
export JVB_AUTH_PASSWORD
export TURN_SECRET
export TURN_SERVER

JICOFO_COMPONENT_SECRET=$(generatePassword jitsi jicofo_secret)
JICOFO_AUTH_PASSWORD=$(generatePassword jitsi jicofo_pwd)
JVB_AUTH_PASSWORD=$(generatePassword jitsi jvb_pwd)

TURN_SERVER="$PRIMARY_DOMAIN_NAME:5349"
TURN_SECRET=$(generatePassword jitsi turn_secret)

if [ "${FLAG_JITSI_USE_EXTERNAL_TURN:-}" == "true" ]
then
	if [ ! -f "$FLAP_DATA/system/data/turn_server.txt" ]
	then
		cat "demo.flap.cloud:5349" > "$FLAP_DATA/system/data/turn_server.txt"
	fi

	TURN_SECRET=''
	TURN_SERVER=$(cat "$FLAP_DATA/system/data/turn_server.txt")
fi
