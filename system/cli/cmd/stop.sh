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

		# Stop all services. If an error occures, the docker daemon will be restarted before retrying.
		echo '* [stop] Stopping services.'
		docker-compose --no-ansi down --remove-orphans || systemctl restart docker || docker-compose --no-ansi down --remove-orphans
		;;
	*)
		# Get services list from args.
		services=("${@:1}")

		for service in "${services[@]}"
		do
			if docker ps --format '{{.Names}}' | grep "flap_$service"
			then
				docker stop "flap_$service"
				docker rm "flap_$service"
			fi
		done
	;;
esac
