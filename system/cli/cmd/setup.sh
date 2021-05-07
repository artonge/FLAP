#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	docker_images)
		if [ ! -f /var/lib/flap/images ]
		then
			exit 0
		fi

		echo "* [start] Load docker images."

		for image in /var/lib/flap/images/*
		do
			docker load "$image"
		done

		rm -rf /var/lib/flap/images
		;;
	hostname)
		if [ "${FLAG_NO_NAT_NETWORK_SETUP:-}" == "true" ]
		then
			exit 0
		fi

		echo '* [setup] Setting hostname'
		hostnamectl --static set-hostname "flap.local"
		hostnamectl --transient set-hostname "flap.local"
		hostnamectl --pretty set-hostname "FLAP box (flap.local $DOMAIN_NAMES)"
	;;
	firewall)
		if [ "${FLAG_NO_FIREWALL_SETUP:-}" == "true" ]
		then
			echo "* [setup:FEATURE_FLAG] Skip firewall setup."
			exit 0
		fi

		echo '* [setup] Setting firewall rules.'

		# Reset ufw.
		ufw --force reset
		ufw --force enable

		# Add default firewall rules.
		ufw default deny incoming
		ufw default allow outgoing

		if [ "${FLAG_NO_NAT_NETWORK_SETUP:-}" != "true" ]
		then
			# Allow packets coming from the port 1900 of a machine on the local network.
			# Allow reception on any port.
			ufw allow from 192.168.0.0/24 port 1900 proto udp to any
		fi

		# Add service's firewall rules.
		for port in $NEEDED_PORTS
		do
			protocol=$(echo "$port" | cut -d '/' -f2)
			port=$(echo "$port" | cut -d '/' -f1)

			echo "Open firewall for $port/$protocol"
			ufw allow "$port/$protocol"
		done
	;;
	fs)
		# Create log folder
		mkdir -p /var/log/flap

		for service in $FLAP_SERVICES
		do
			# Skip if the directory is already created.
			if [ ! -d "$FLAP_DATA/$service" ]
			then
				echo "* [setup] Creating data directories for $service."
	
				# Create data directory for the service.
				debug "Create $FLAP_DATA/$service"
				mkdir --parents "$FLAP_DATA/$service"
			fi

			# If current_migration is not set, set it based on the migrations scripts.
			if [ ! -f "$FLAP_DATA/$service/current_migration.txt" ]
			then
				current_migration="0"
				while [ -f "$FLAP_DIR/$service/scripts/migrations/$((current_migration+1)).sh" ]
				do
					current_migration=$((current_migration+1))
				done
				debug "Setup base migration of $current_migration for $service"
				echo "$current_migration" > "$FLAP_DATA/$service/current_migration.txt"
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
		for service in $FLAP_SERVICES
		do
			if [ -f "$FLAP_DIR/$service/$service.cron" ]
			then
				debug "- $service.cron"
				cron_string+="############## $service ##############"$'\n'
				cron_string+="$(cat "$service/$service.cron")"$'\n\n'
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
		hostname | | Setup local hostname.
		firewall | | Setup firewall rules.
		fs | | Create FLAP's data files structure.
		cron | | Setup the cron from service's cron files." | column -t -s "|"
	;;
esac
