#!/bin/bash

set -eux

# Version v1.14.6

echo "* [23] Remove all present ENABLE_<service> variables in flapctl.env."
flapctlenv=$(grep -v 'ENABLE_' "$FLAP_DATA"/system/flapctl.env)
echo "$flapctlenv" > "$FLAP_DATA"/system/flapctl.env

echo "* [23] Write all ENABLE_<service> variable in flapctl.env."
{
	echo "export ENABLE_NEXTCLOUD=${ENABLE_NEXTCLOUD:-true}"
	echo "export ENABLE_SOGO=${ENABLE_SOGO:-true}"
	echo "export ENABLE_MATRIX=${ENABLE_MATRIX:-true}"
	echo "export ENABLE_JITSI=${ENABLE_JITSI:-true}"
	echo "export ENABLE_PEERTUBE=${ENABLE_PEERTUBE:-false}"
	echo "export ENABLE_FUNKWHALE=${ENABLE_FUNKWHALE:-false}"
	echo "export ENABLE_MONITORING=${ENABLE_MONITORING:-false}"
	echo "export ENABLE_MATOMO=${ENABLE_MATOMO:-false}"
	echo "export ENABLE_WEBLATE=${ENABLE_WEBLATE:-false}"
} >> "$FLAP_DATA"/system/flapctl.env