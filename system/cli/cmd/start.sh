#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	"")
		echo '* [start] Running setup operations.'
		# Run some setup operation if the installation is not done.
		if [ ! -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			flapctl setup raid
			flapctl setup network
		fi
		flapctl setup cron
		flapctl setup fs

		# Go to FLAP_DIR for docker-compose.
		cd "$FLAP_DIR"

		# Generate config
		flapctl config generate

		# Clean volumes and networks of services.
		flapctl hooks clean

		# Start all services.
		echo '* [start] Starting services.'
		docker-compose --no-ansi up --detach

		if [ ! -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			# Run post setup scripts for each services.
			flapctl hooks post_install

			# Mark the installation as done.
			touch "$FLAP_DATA/system/data/installation_done.txt"
		fi

		# Generate certificates for flap.localhost on DEV mode, but not during tests.
		if [ "${DEV:-false}" == "true" ] && [ "$(flapctl tls primary)" == "" ] && [ "${TEST:-false}" == "false" ]
		then
			flapctl tls generate_localhost
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
