#!/bin/bash

set -ue

mkdir --parents "$FLAP_DATA/system"

# shellcheck source=system/flapctl.examples.d/pipeline.env
# shellcheck disable=SC1091
source "$FLAP_DATA/system/flapctl.env"

# Export global environnement variables.
export PRIMARY_DOMAIN_NAME
PRIMARY_DOMAIN_NAME=$("$FLAP_LIBS/tls/show_primary_domain.sh")

export DOMAIN_NAMES
DOMAIN_NAMES=$("$FLAP_LIBS/tls/list_domains.sh" | { grep OK || true; } | cut -d ' ' -f1 | paste -sd " " -)

export SECONDARY_DOMAIN_NAMES
SECONDARY_DOMAIN_NAMES="${DOMAIN_NAMES//${PRIMARY_DOMAIN_NAME:-"none"}/}"

export SUBDOMAINS
SUBDOMAINS=""

export NEEDED_PORTS
NEEDED_PORTS=""

export FLAP_ENV_VARS
FLAP_ENV_VARS="\${ADMIN_EMAIL} \${FLAP_SERVICES} \${PRIMARY_DOMAIN_NAME} \${SECONDARY_DOMAIN_NAMES} \${DOMAIN_NAMES} \${NEEDED_PORTS} \${ARCH} \${FLAP_VERSION}"

export FLAP_SERVICES
FLAP_SERVICES=""

export ARCH
ARCH=$(uname -m)

cd "$FLAP_DIR"
export FLAP_VERSION
FLAP_VERSION=$(git describe --tags --abbrev=0)


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

# Load services environnement variables.
# This will populate FLAP_ENV_VARS, SUBDOMAINS and NEEDED_PORTS.
for service in $FLAP_SERVICES
do
	if [ ! -f "$service/scripts/hooks/load_env.sh" ]
	then
		continue
	fi

	# shellcheck source=system/scripts/hooks/load_env.sh
	# shellcheck disable=SC1091
	source "$service/scripts/hooks/load_env.sh"
done