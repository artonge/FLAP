#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	network)
		if [ "${FLAG_NO_NETWORK_SETUP:-}" == "true" ]
		then
			echo "* [setup] Skip network setup."
			exit 0
		fi

		echo '* [setup] Setting hostname'
		# Set local domain name to flap.local
		hostnamectl --static set-hostname "$PRIMARY_DOMAIN_NAME"
		hostnamectl --transient set-hostname "flap.local"
		hostnamectl --pretty set-hostname "FLAP box (flap.local)"
		echo '* [setup] Openning ports'
		# Create port mappings
		flapctl ports open 22 # SSH
		flapctl ports open 80 # HTTP
		flapctl ports open 443 # HTTPS
		flapctl ports open 25 # SMTP
		flapctl ports open 587 # SMTP with STARTLS
		flapctl ports open 143 # IMAP
	;;
	raid)
		echo '* [setup] Setting up RAID.'
		flapctl disks setup
	;;
	fs)
		echo '* [setup] Creating data directories.'

		# Create log folder
		mkdir -p /var/log/flap

		for service in "$FLAP_DIR"/*/
		do
			if [ ! -d "$service" ]
			then
				continue
			fi

			service=$(basename "$service")

			echo - "$service"

			# Skip if the directory is allready created.
			if [ ! -d "$FLAP_DATA/$service" ]
			then
				# Create data directory for the service.
				echo "	Create $FLAP_DATA/$service"
				mkdir -p "$FLAP_DATA/$service"
			fi

			# If current_migration is not set, set it based on the migrations scripts.
			if [ ! -f "$FLAP_DATA/$service/current_migration.txt" ]
			then
				current_migration="0"
				while [ -f "$FLAP_DIR/$service/scripts/migrations/$((current_migration+1)).sh" ]
				do
					current_migration=$((current_migration+1))
				done
				echo "	Setup base migration of $current_migration"
				echo $current_migration > "$FLAP_DATA/$service/current_migration.txt"
			fi
		done
	;;
	cron)
		if [ "${FLAG_NO_CRON_SETUP:-}" == "true" ]
		then
			echo "* [setup:FEATURE_FLAG] Skip cron generation."
			exit 0
		fi

		echo '* [setup] Generating main cron file from services cron files'

		cron_string="############## ENV ##############"$'\n'
		cron_string+="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"$'\n\n'

		# Build cron_string from services cron files
		for service in "$FLAP_DIR"/*/
		do
			if [ ! -d "$service" ]
			then
				continue
			fi

			if [ -f "$service/$(basename "$service").cron" ]
			then
				echo - "$(basename "$service").cron"
				cron_string+="############## $(basename "$service") ##############"$'\n'
				cron_string+="$(cat "$service/$(basename "$service").cron")"$'\n\n'
			fi
		done

		# Set the built string as the cron file
		echo "$cron_string" | crontab -
	;;
	summarize)
		echo "setup | [cron, help] | Setup FLAP components."
	;;
	help|*)
		echo "
	setup | Setup FLAP components.
	Commands:
		cron | | Setup the cron from service's cron files.
		network | | Setup the network (ports mapping and mDNS).
		raid | | Setup the RAID and directories used by FLAP." | column -t -s "|"
	;;
esac
