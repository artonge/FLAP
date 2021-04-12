#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	generate)
		flapctl config generate_templates
		flapctl hooks generate_config
		;;
	generate_templates)
		echo '* [config] Generate template files.'

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
