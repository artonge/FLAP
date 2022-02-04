#!/bin/bash

set -euo pipefail


debug "Set lemonLDAP SAML keys."
config=$(cat "$FLAP_DIR/lemon/config/lmConf-1.base.json")

if [ -f "$FLAP_DATA/lemon/saml/private_key.pem" ]
then
	echo "$config" | \
		jq --arg privateKey "$(cat "$FLAP_DATA/lemon/saml/private_key.pem")" '.samlServicePrivateKeySig=$privateKey' | \
		jq --arg publicKey  "$(cat "$FLAP_DATA/lemon/saml/cert.pem")" '.samlServicePublicKeySig=$publicKey' \
	> "$FLAP_DIR/lemon/config/lmConf-1.json"
fi

debug "Add services config to the lemonLDAP config."
for service in $FLAP_SERVICES
do
	debug "- $service"
	for domain in $DOMAIN_NAMES
	do
		# Check if lemon config exists for the service.
		if [ ! -f "$FLAP_DIR/$service/config/lemon.jq" ]
		then
			continue
		fi

		debug "  - $domain"

		vhostType='CDA'
		[ -f "$FLAP_DATA/$service/saml/metadata_$domain.xml" ] && metadata=$(cat "$FLAP_DATA/$service/saml/metadata_$domain.xml")
		config=$(cat "$FLAP_DIR/lemon/config/lmConf-1.json")

		# Add a vhost for each domains.
		jq \
			--null-input \
			--arg domain "$domain" \
			--arg vhostType "$vhostType" \
			--arg samlMetadata "${metadata:-}" \
			--from-file "$FLAP_DIR/$service/config/lemon.jq" | \
		jq \
			--slurp \
			--argjson config \
			"$config" '.[0] * $config' \
		> "$FLAP_DIR/lemon/config/lmConf-1.json"
	done
done
