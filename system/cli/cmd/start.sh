#!/bin/bash

set -euo pipefail

CMD=${1:-}

case $CMD in
	summarize)
		echo "start | [<service> ...] | Start services. Will generate template and run generate_config hooks."
	;;
	help)
		echo "
$(flapctl start summarize)
Commands:
	[<service-name> ...] | | Start the given services, or start them all if nothing is provided." | column -t -s "|"
	;;
	"")
		echo '* [start] Starting services.'
		# Run some setup operations if necessary.
		if [ ! -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			flapctl setup hostname
			flapctl setup certbot_renewal_hooks
			flapctl setup docker_images
			flapctl disks setup
		fi

		flapctl setup fs

		flapctl migrate

		echo '* [start] Generating config for startup.'
		flapctl config generate

		flapctl hooks init_db
		flapctl hooks pre_install

		flapctl hooks clean

		# Go to FLAP_DIR for docker-compose.
		cd "$FLAP_DIR"
		echo '* [start] Running services.'
		if [ "${FLAP_DEBUG:-}" == "true" ]
		then
			docker-compose --ansi never up --quiet-pull --detach
		else
			docker-compose --ansi never up --quiet-pull --remove-orphans --detach 2> /dev/stdout | { grep -v -E '(^Creating)|(is up-to-date$)' || true; }
		fi

		# Wait for services to be up.
		flapctl wait_ready

		# Run post install hooks.
		flapctl hooks post_install

		if [ ! -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			# Mark the installation as done.
			touch "$FLAP_DATA/system/data/installation_done.txt"
		fi
	;;
	*)
		services=("${@:1}")

		flapctl config generate_templates
		flapctl hooks generate_config system "${services[@]}"

		sub_services=()
		for service in "${services[@]}"
		do
			mapfile -t tmp_services < <(yq -r '.services | keys[]' "$FLAP_DIR/$service/docker-compose.yml");
			sub_services+=("${tmp_services[@]}")
		done

		docker-compose --ansi never up --quiet-pull --remove-orphans --detach "${sub_services[@]}" 2> /dev/stdout | { grep -v -E '(^Creating)|(is up-to-date$)' || true; }

		flapctl wait_ready "${services[@]}"
	;;
esac
