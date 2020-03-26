#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	"")
		echo '* [start] Running setup operations.'

		if [ -f /var/lib/flap/images ]
		then
			echo "* [start] Load docker images."

			for image in /var/lib/flap/images/*
			do
				docker load "$image"
			done

			rm -rf /var/lib/flap/images
		fi

		# Run some setup operations if necessary.
		flapctl setup raid
		flapctl setup hostname
		flapctl setup fs

		if [ "${FLAG_NO_RAID_SETUP:-false}" == "false" ]
		then
			# Check that the RAID array is correctly mounted.
			findmnt "$FLAP_DATA"
		fi

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
			# Run other setup operations.
			flapctl setup ports
			flapctl setup cron

			# Run post setup scripts for each services.
			flapctl hooks post_install

			# Mark the installation as done.
			touch "$FLAP_DATA/system/data/installation_done.txt"
		fi

		if [ "${FLAG_LOCALHOST_TLS_INSTALL:-}" == "true" ] && [ "$(flapctl tls primary)" == "" ]
		then
			# Generate certificates for flap.localhost.
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
