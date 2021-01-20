#!/bin/bash

set -ue

mkdir --parents "$FLAP_DATA/system"

# shellcheck source=./system/flapctl.exemple.d/flapctl.vps.env
# shellcheck disable=SC1091
source "$FLAP_DATA/system/flapctl.env"

# Export global environement variables.
export PRIMARY_DOMAIN_NAME
PRIMARY_DOMAIN_NAME=$("$FLAP_LIBS/tls/show_primary_domain.sh")

export DOMAIN_NAMES
DOMAIN_NAMES=$("$FLAP_LIBS/tls/list_domains.sh" | grep OK | cut -d ' ' -f1 | paste -sd " " -)

export SECONDARY_DOMAIN_NAMES
SECONDARY_DOMAIN_NAMES="${DOMAIN_NAMES//${PRIMARY_DOMAIN_NAME:-"none"}/}"

export SUBDOMAINS
SUBDOMAINS=""

export NEEDED_PORTS
NEEDED_PORTS=""

export FLAP_ENV_VARS
FLAP_ENV_VARS="\${ADMIN_EMAIL} \${FLAP_SERVICES} \${PRIMARY_DOMAIN_NAME} \${SECONDARY_DOMAIN_NAMES} \${DOMAIN_NAMES} \${NEEDED_PORTS}"

# Load services environement variables.
# This will populate FLAP_ENV_VARS, SUBDOMAINES and NEEDED_PORTS.
for service in "$FLAP_DIR"/*/
do
	if [ ! -f "$service/scripts/hooks/load_env.sh" ]
	then
		continue
	fi

	# shellcheck source=jitsi/scripts/hooks/load_env.sh
	source "$service/scripts/hooks/load_env.sh"
done


export FLAP_SERVICES
FLAP_SERVICES=""

# Populate FLAP_SERVICES with activated services.
for service in "$FLAP_DIR"/*
do
	if [ ! -d "$service" ]
	then
		continue
	fi

	if [ -f "$service/scripts/hooks/should_install.sh" ] && ! "$service/scripts/hooks/should_install.sh"
	then
		continue
	fi

	FLAP_SERVICES="$FLAP_SERVICES $(basename "$service")"
done

# Trim leading white space.
FLAP_SERVICES=${FLAP_SERVICES:1}
