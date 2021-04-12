#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	summarize)
		echo "start | | Start flap services."
		;;
	help)
		echo "
$(flapctl start summarize)
Commands:
	'' | | Start." | column -t -s "|"
	;;
	"")
		echo '* [start] Starting services.'
		# Run some setup operations if necessary.
		if [ ! -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			flapctl setup hostname
			flapctl setup docker_images
			flapctl disks setup
		fi

		flapctl setup fs

		flapctl migrate

		echo '* [start] Generating config.'
		flapctl config generate

		flapctl hooks init_db
		flapctl hooks pre_install

		flapctl hooks clean

		# Go to FLAP_DIR for docker-compose.
		cd "$FLAP_DIR"
		echo '* [start] Running services.'
		docker-compose --ansi never up --quiet-pull --detach 2> /dev/stdout | grep -v -E '^Creating' | cat

		# Wait dor services to be up.
		flapctl hooks wait_ready

		# Run post install hooks.
		flapctl hooks post_install

		if [ ! -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			# Mark the installation as done.
			touch "$FLAP_DATA/system/data/installation_done.txt"
		fi

		if [ "${FLAG_LOCALHOST_TLS_INSTALL:-}" == "true" ] && [ "$(flapctl domains primary)" == "" ]
		then
			flapctl domains generate_local flap.test
		fi
		;;
	*)
		services=("${@:1}")

		flapctl config generate_templates
		flapctl hooks generate_config system "${services[@]}"

		docker-compose --ansi never up --quiet-pull --remove-orphans --detach "${services[@]}"

		flapctl hooks wait_ready "${services[@]}"
		;;
esac
