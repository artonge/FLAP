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

		# Generate configuration so docker-compose does not complains because of a missing config file.
		flapctl config generate_templates
		flapctl hooks generate_config system

		# Stop all services. If an error occurs, the docker daemon will be restarted before retrying.
		echo '* [stop] Stopping services.'
		docker-compose down --remove-orphans || systemctl restart docker || docker-compose down --remove-orphans
		;;
	*)
		# Get services list from args.
		services=("${@:1}")
		services_list=()

		for service in "${services[@]}"
		do
			if docker ps --format '{{.Names}}' | grep "flap_$service"
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
