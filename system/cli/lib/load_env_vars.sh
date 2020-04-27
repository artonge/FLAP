#!/bin/bash

set -ue


# Load feature flags.
if [ -f "$FLAP_DATA/system/flapctl.env" ]
then
	# shellcheck source=flapctl.example.env
	# shellcheck disable=SC1091
	source "$FLAP_DATA/system/flapctl.env"
fi


# Export global environement variables.
export ARCH
ARCH=$(uname -m)

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
FLAP_ENV_VARS="\${ARCH} \${FLAP_SERVICES} \${PRIMARY_DOMAIN_NAME} \${SECONDARY_DOMAIN_NAMES} \${DOMAIN_NAMES} \${NEEDED_PORTS}"


# Load the admin email.
# If admin_email.txt does not exist, try to load it from flap_init_config.yml.
export ADMIN_EMAIL
if [ ! -f "$FLAP_DATA/system/admin_email.txt" ]
then
	if [ -f "$FLAP_DIR/flap_init_config.yml" ]
	then
		admin_mail=$(yq --raw-output '.admin_mail' "$FLAP_DIR/flap_init_config.yml")
		if [ "$admin_mail" != "" ]
		then
			echo "$admin_mail" > "$FLAP_DATA/system/admin_email.txt"
			ADMIN_EMAIL=$admin_mail
		fi
	fi
else
	ADMIN_EMAIL=$(cat "$FLAP_DATA/system/admin_email.txt")
fi


export FLAP_SERVICES
FLAP_SERVICES=""

# Ppopulate FLAP_SERVICES with activated services.
for service in "$FLAP_DIR"/*/
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


# Load services environement variables.
# This will populate FLAP_ENV_VARS, SUBDOMAINES and NEEDED_PORTS.
# HACK: We do not use FLAP_SERVICES because some services can need some other services env var even if it is disabled.
# This will be changed in the future so only the env var of enabled services are loaded.
# See: https://gitlab.com/flap-box/flap/-/issues/62
for service in "$FLAP_DIR"/*/
do
	if [ ! -f "$service/scripts/hooks/load_env.sh" ]
	then
		continue
	fi

	# shellcheck source=jitsi/scripts/hooks/load_env.sh
	source "$service/scripts/hooks/load_env.sh"
done
