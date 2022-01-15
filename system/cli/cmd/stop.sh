#!/bin/bash

set -euo pipefail

CMD=${1:-}

case $CMD in
	summarize)
		echo "stop | | Stop flap services."
		echo "stop | <service> [<service> ...] | Stop specific services."
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
		if [ "${FLAP_DEBUG:-}" == "true" ]
		then
			docker-compose --ansi never down --remove-orphans | cat
		else
			docker-compose --ansi never down --remove-orphans 2> /dev/stdout | grep -v -E '^Stopping' | grep -v -E '^Removing' | cat
		fi

		exit_code=${PIPESTATUS[0]}
		if [ "$exit_code" != "0" ]
		then
			{
				flapctl config generate &&
				docker-compose down --remove-orphans
			} || {
				sleep 10 &&
				docker-compose down --remove-orphans
			} || {
				systemctl restart docker &&
				docker-compose down --remove-orphans
			}
		fi
		;;
	*)
		# Get services list from args.
		services=("${@:1}")
		services_list=()

		sub_services=()
		for service in "${services[@]}"
		do
			mapfile -t tmp_services < <(yq -r '.services | keys[]' "$FLAP_DIR/$service/docker-compose.yml");
			sub_services+=("${tmp_services[@]}")
		done

		for service in "${sub_services[@]}"
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
