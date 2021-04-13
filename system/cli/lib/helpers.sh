#!/bin/bash

set -ue

# generatePassword <service> <var_name>
# Will store a password in a file in the service's `passwd` directory.
generatePassword() {
	if [ ! -f "$FLAP_DATA/$1/passwd/$2.txt" ]
	then
		mkdir --parents "$FLAP_DATA/$1/passwd"
		openssl rand --hex 32 > "$FLAP_DATA/$1/passwd/$2.txt"
	fi

	cat "$FLAP_DATA/$1/passwd/$2.txt"
}
export -f generatePassword


# debug <string>
debug() {
	if "${FLAP_DEBUG:-false}"
	then
		echo "$1"
	fi
}
export -f debug

# get_saml_metadata <service> <domain> <url>
# Get the metadata of a service at a given URL and store them in a generic folder.
get_saml_metadata() {
	service=$1
	domain=$2
	url=$3

	args=()

	# Check certificates with local CA for local domains.
	provider=$(cat "$FLAP_DATA/system/data/domains/$domain/provider.txt")
	if [ "$provider" == "local" ]
	then
		args+=(--cacert /etc/letsencrypt/live/flap/root.cer)
	fi

	if [ "${FLAP_DEBUG:-}" != "true" ]
	then
		args+=(--silent)
	fi

	debug "Fetching $service's SAML metadata for $domain."
	curl "$url" --output "$FLAP_DATA/$service/saml/metadata_$domain.xml" "${args[@]}"
}
export -f get_saml_metadata