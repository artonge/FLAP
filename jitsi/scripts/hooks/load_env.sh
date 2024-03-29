#!/bin/bash

set -euo pipefail


# shellcheck disable=SC2016
FLAP_ENV_VARS="$FLAP_ENV_VARS \${JICOFO_COMPONENT_SECRET} \${JICOFO_AUTH_PASSWORD} \${JVB_AUTH_PASSWORD} \${TURN_SECRET} \${TURN_SERVER} \${COTURN_LOCAL_ALLOWED_IP}"
SUBDOMAINS="$SUBDOMAINS coturn jitsi"
# 3478 - TURN server
# 5349 - TURNS server
# 10000/UDP - RTP/UDP
# 4443 - RTP/TCP fallback
NEEDED_PORTS="$NEEDED_PORTS 5349/tcp 5349/udp 3478/tcp 3478/udp 4443/udp 10000/udp"

export JICOFO_COMPONENT_SECRET
export JICOFO_AUTH_PASSWORD
export JVB_AUTH_PASSWORD
export TURN_SECRET
export TURN_SERVER
export COTURN_LOCAL_ALLOWED_IP

JICOFO_COMPONENT_SECRET=$(generatePassword jitsi jicofo_secret)
JICOFO_AUTH_PASSWORD=$(generatePassword jitsi jicofo_pwd)
JVB_AUTH_PASSWORD=$(generatePassword jitsi jvb_pwd)

TURN_SERVER="$PRIMARY_DOMAIN_NAME:5349"
TURN_SECRET=$(generatePassword jitsi turn_secret)

if [ "${FLAG_JITSI_USE_EXTERNAL_TURN:-}" == "true" ]
then
	if [ ! -f "$FLAP_DATA/system/data/turn_server.txt" ]
	then
		echo "demo.flap.cloud" > "$FLAP_DATA/system/data/turn_server.txt"
	fi

	TURN_SECRET='default_password'
	TURN_SERVER=$(cat "$FLAP_DATA/system/data/turn_server.txt")
fi

# Get the IP that must be whitelisted for communicating with itself.
COTURN_LOCAL_ALLOWED_IP=$(ip --json -4 a | jq --raw-output .[1].addr_info[0].local)
