#!/bin/bash

set -eu

CMD=${1:-}

case $CMD in
	summarize)
		echo "stop | | Stop flap services."
	;;
	help)
		echo "
$(flapctl stop summarize)
Commands:
	'' | | STOP." | column -t -s "|"
	;;
	"")
		# Go to FLAP_DIR for docker-compose.
		cd "$FLAP_DIR"

		# Stop all services and grep-out output. If an error occurs:
		# - regenerate the config and retry.
		# - if it still persist, restart the docker daemon and retry.
		echo '* [stop] Stopping services.'
		{
			docker-compose --ansi never down --remove-orphans 2> /dev/stdout | grep -v -E '^Stopping' | grep -v -E '^Removing' | cat
		} || {
			flapctl config generate
			docker-compose down --remove-orphans
		} || { 
			systemctl restart docker
			docker-compose down --remove-orphans
		}
		;;
	*)
		# Get services list from args.
		services=("${@:1}")
		services_list=()

		for service in "${services[@]}"
		do
			if docker ps --format '{{.Names}}' | grep -E "flap_$service$"
			then
				services_list+=("flap_$service")
			fi
		done

		if [ "${#services_list[@]}" != "0" ]
		then
			docker stop "${services_list[@]}"
			docker rm "${services_list[@]}"
		fi
	;;
esac
