#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	"")
		echo '* [start] Running setup operations.'

		# Run some setup operations if necessary.
		if [ ! -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			flapctl setup flapenv
			flapctl setup hostname
			flapctl setup docker_images
			flapctl disks setup
			# Run 'setup flapenv' twice because 'disk setup' could have destroy it.
			flapctl setup flapenv
			flapctl ip setup
		fi

		flapctl setup fs

		# Generate config.
		flapctl config generate

		# Run init and install hooks.
		flapctl hooks init_db
		flapctl hooks pre_install

		# Clean volumes and networks of services.
		flapctl hooks clean

		# Go to FLAP_DIR for docker-compose.
		cd "$FLAP_DIR"

		echo '* [start] Starting services.'
		export COMPOSE_HTTP_TIMEOUT=120
		docker-compose --no-ansi up --detach

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
	summarize)
		echo "start | | Start flap services."
		;;
	help|*)
		echo "
$(flapctl start summarize)
Commands:
	'' | | Start." | column -t -s "|"
	;;
esac
