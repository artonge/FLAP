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
		flapctl setup firewall

		# Generate config
		flapctl config generate

		# Run init and install hooks.
		flapctl hooks init_db
		flapctl hooks pre_install

		# Clean volumes and networks of services.
		flapctl hooks clean

		# Go to FLAP_DIR for docker-compose.
		cd "$FLAP_DIR"

		echo '* [start] Starting services.'
		docker-compose --no-ansi up --detach

		# Run post install hooks.
		flapctl hooks post_install

		if [ ! -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			# Run other setup operations.
			flapctl setup ports
			flapctl setup cron

			# Mark the installation as done.
			touch "$FLAP_DATA/system/data/installation_done.txt"
		fi

		if [ "${FLAG_LOCALHOST_TLS_INSTALL:-}" == "true" ] && [ "$(flapctl tls primary)" == "" ]
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
