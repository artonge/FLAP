#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	generate)
		flapctl config generate_templates
		flapctl config generate_nginx
		flapctl hooks generate_config
		;;
	generate_nginx)
		echo "* [config] Generating Nginx config files."
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
		;;
	generate_templates)
		echo '* [config] Generate template final files from the current config'

		# Go to FLAP_DIR to have access to template files.
		cd "$FLAP_DIR"

		# Transform each files matching *.template.*
		shopt -s globstar nullglob
		for template in "$FLAP_DIR"/**/*.template.*
		do
			dir=$(dirname "$template") # Get template's directory
			name=$(basename "$template") # Get template's name (without the directory)
			ext="${name##*.}"
			name="${name%.*}" # Remove extension
			name="${name%.*}" # Remove ".template"

			# shellcheck disable=SC2016
			envsubst "$FLAP_ENV_VARS" < "$dir/$name.template.$ext" > "$dir/$name.$ext"
		done
		;;
	show)
		vars_string=""

		for var in $FLAP_ENV_VARS
		do
			vars_string+="export ${var//[\$\{\}]/}='$(eval "echo $var")'"$'\n'
		done

		echo "$vars_string" | column -t -s '|'
		;;
	summarize)
		echo "config | [generate, show, help] | Generate the configuration for each services."
		;;
	help|*)
		echo "
$(flapctl config summarize)
Commands:
	generate | | Generate the services config files from the current config variables.
	generate_templates | | Render templates.
	show | | Show the current config variables." | column -t -s "|"
		;;
esac
