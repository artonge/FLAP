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
		echo '* [start] Running setup operations.'

		# Run some setup operations if necessary.
		if [ ! -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			flapctl setup hostname
			flapctl setup docker_images
			flapctl disks setup
		fi

		flapctl setup fs

		flapctl migrate

		flapctl config generate

		flapctl hooks init_db
		flapctl hooks pre_install

		# Clean volumes and networks of services.
		flapctl hooks clean

		# Go to FLAP_DIR for docker-compose.
		cd "$FLAP_DIR"

		echo '* [start] Starting services.'
		if [ "${CI_JOB_NAME:-}" != "setup_with_serial_updates" ]
		then
			docker-compose --no-ansi up --detach
		else
			# Debug overlapping network error happening during serial updates.
			ip a
			docker-compose --verbose --log-level DEBUG --no-ansi up --detach
		fi

		# Wait dor services to be up.
		flapctl hooks wait_ready

		# Run post install hooks.
		flapctl hooks post_install

		if [ ! -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			# Run other setup operations.
			flapctl ports setup
			flapctl setup firewall
			flapctl setup cron

			# Mark the installation as done.
			touch "$FLAP_DATA/system/data/installation_done.txt"
		fi

		if [ "${FLAG_LOCALHOST_TLS_INSTALL:-}" == "true" ] && [ "$(flapctl domains primary)" == "" ]
		then
			# Generate certificates for flap.test.
			flapctl tls generate_localhost
			flapctl restart
			flapctl hooks post_domain_update
		fi
		;;
	*)
		# Get services list from args.
		services=("${@:1}")

		flapctl config generate_templates
		flapctl hooks generate_config "${services[@]}"

		docker-compose --no-ansi up --detach "${services[@]}"
		;;
esac
