#!/bin/bash

set -eu

debug "Generating Nginx config files."
debug "Create Nginx directory structure."
mkdir -p "$FLAP_DIR/nginx/config/conf.d/domains"

debug "Reset domains' includes files."
if [ "$PRIMARY_DOMAIN_NAME" == "" ]
then
	echo "" > "$FLAP_DIR/nginx/config/conf.d/domains.conf"
else
	echo "include /etc/nginx/parts.d/tls.inc;" > "$FLAP_DIR/nginx/config/conf.d/domains.conf"
fi

debug "Clean old domains config files."
rm -rf "$FLAP_DIR"/nginx/config/conf.d/domains/*

debug 'Generate Nginx configurations files for each domains.'
# shellcheck disable=SC2153
for domain in $DOMAIN_NAMES
do
	debug "- $domain"
	echo "include /etc/nginx/conf.d/domains/$domain/*.conf;" >> "$FLAP_DIR/nginx/config/conf.d/domains.conf"
	mkdir -p "$FLAP_DIR/nginx/config/conf.d/domains/$domain"

	for service in $FLAP_SERVICES
	do
		if [ -f "$FLAP_DIR/$service/nginx.conf" ]
		then
			debug "  + $service"
			export DOMAIN_NAME="$domain"
			envsubst "$FLAP_ENV_VARS \${DOMAIN_NAME}" < "$FLAP_DIR/$service/nginx.conf" > "$FLAP_DIR/nginx/config/conf.d/domains/$domain/$service.conf"
		fi
	done
done

debug "Copy all nginx-extra files."
rm -rf "$FLAP_DIR/nginx/config/conf.d/extra.d"
mkdir -p "$FLAP_DIR/nginx/config/conf.d/extra.d"
rm -f "$FLAP_DIR/nginx/config/conf.d/extra.conf"
touch "$FLAP_DIR/nginx/config/conf.d/extra.conf"
for service in $FLAP_SERVICES
do
	for config in "$FLAP_DIR/$service"/config/nginx-*-extra.conf
	do
		[[ -e "$config" ]] || break # break if config does not exists.

		cp "$config" "$FLAP_DIR/nginx/config/conf.d/extra.d/"
		echo "include /etc/nginx/conf.d/extra.d/$(basename "$config");" >> "$FLAP_DIR/nginx/config/conf.d/extra.conf"
	done
done

debug "Copy all nginx-root files."
rm -rf "$FLAP_DIR/nginx/config/conf.d/root.d"
mkdir -p "$FLAP_DIR/nginx/config/conf.d/root.d"
rm -f "$FLAP_DIR/nginx/config/conf.d/root.conf"
touch "$FLAP_DIR/nginx/config/conf.d/root.conf"
for service in $FLAP_SERVICES
do
	for config in "$FLAP_DIR/$service"/config/nginx-*-root.conf
	do
		[[ -e "$config" ]] || break # break if config does not exists.

		cp "$config" "$FLAP_DIR/nginx/config/conf.d/root.d/"
		echo "include /etc/nginx/conf.d/root.d/$(basename "$config");" >> "$FLAP_DIR/nginx/config/conf.d/root.conf"
	done
done
