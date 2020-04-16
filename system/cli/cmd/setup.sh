#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	hostname)
		if [ "${FLAG_NO_NAT_NETWORK_SETUP:-}" == "true" ]
		then
			echo "* [setup:FEATURE_FLAG] Skip hostnames setup."
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

		# Add services's firewall rules.
		for port in $NEEDED_PORTS
		do
			protocol=$(echo "$port" | cut -d '/' -f2)
			port=$(echo "$port" | cut -d '/' -f1)

			echo "Open firewall for $port/$protocol"
			ufw allow "$port/$protocol"
		done
	;;
	ports)
		# Exit now if feature is disabled.
		if [ "${FLAG_NO_NAT_NETWORK_SETUP:-}" == "true" ]
		then
			echo "* [setup:FEATURE_FLAG] Skip opening port."
			exit 0
		fi

		echo '* [setup] Openning ports.'

		ip=$(flapctl ip internal)
		echo "Internal ip is: $ip"

		if [ "${FLAG_NO_FIREWALL_SETUP:-}" != "true" ]
		then
			# Disable ufw to allow upnp to work.
			ufw --force disable
		fi

		open_ports=$(flapctl ports list)

		# Open ports.
		for port in $NEEDED_PORTS
		do
			protocol=$(echo "$port" | cut -d '/' -f2 | tr '[:lower:]' '[:upper:]')
			port=$(echo "$port" | cut -d '/' -f1)

			if echo "$open_ports" | grep "$protocol" | grep "$ip:$port"
			then
				echo "Port $port/$protocol is already open."
				continue
			fi

			flapctl ports open "$port" "$protocol" "$ip"
		done

		if [ "${FLAG_NO_FIREWALL_SETUP:-}" != "true" ]
		then
			ufw --force enable
		fi
	;;
	raid)
		echo '* [setup] Setting up RAID.'
		flapctl disks setup

		if [ "${FLAG_NO_RAID_SETUP:-}" == "true" ]
		then
			exit 0
		fi

		# Check that the RAID array is correctly mounted.
		findmnt "$FLAP_DATA"
	;;
	hosting)
		if [ "${FLAG_SETUP_HOSTING:-}" != "true" ]
		then
			echo "* [setup:FEATURE_FLAG] Skip hosting setup."
			exit 0
		fi

		if findmnt "$FLAP_DATA"
		then
			exit 0
		fi

		mkdir --parents "$FLAP_DATA/system/data"

		echo '* [setup] Checking disk status.'
		if [ ! -f "$FLAP_DATA/system/data/disk.txt" ]
		then
			echo "/dev/sda" > "$FLAP_DATA/system/data/disk.txt"
		fi

		disk=$(cat "$FLAP_DATA/system/data/disk.txt")

		mount "$disk" "$FLAP_DATA"
		if [ -f "$FLAP_DATA/system/data/installation_done.txt" ]
		then
			echo '* [setup] Disk is a FLAP install, exiting.'
			exit 0
		else
			echo '* [setup] Disk is not a FLAP install.'
			umount "$FLAP_DATA"
		fi

		echo '* [setup] Seting up disk for FLAP.'
		mkfs -t ext4 "$disk"
		mount "$disk" "$FLAP_DATA"
		mkdir --parents "$FLAP_DATA/system/data"
		echo "$disk" > "$FLAP_DATA/system/data/disk.txt"

		echo "* [setup] Setting static IP"
		mkdir --parents "$FLAP_DATA/system/data"
		curl -4 https://icanhazip.com 2>/dev/null > "$FLAP_DATA/system/data/fixed_ip.txt"
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

			if [ -f "$service/scripts/hooks/should_install.sh" ] && ! "$service/scripts/hooks/should_install.sh"
			then
				continue
			fi

			service=$(basename "$service")

			# Skip if the directory is allready created.
			if [ ! -d "$FLAP_DATA/$service" ]
			then
				# Create data directory for the service.
				echo "Create $FLAP_DATA/$service"
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
				echo "Setup base migration of $current_migration for $service"
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

			if [ -f "$service/scripts/hooks/should_install.sh" ] && ! "$service/scripts/hooks/should_install.sh"
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
